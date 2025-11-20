import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pocket_ledger_app/core/theme/app_color.dart';
import 'package:pocket_ledger_app/core/utils/export_utils.dart';
import 'package:pocket_ledger_app/domain/models/transaction_model.dart';
import 'package:pocket_ledger_app/presentation/components/responsive_scaffold.dart';
import 'package:pocket_ledger_app/presentation/providers/transaction_provider.dart';
import 'package:pocket_ledger_app/presentation/providers/wallet_provider.dart';
import 'package:pocket_ledger_app/presentation/routes/app_router.gr.dart';

@RoutePage()
class TransactionPage extends ConsumerStatefulWidget {
  const TransactionPage({super.key});

  @override
  ConsumerState<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController amountController;
  late final TextEditingController noteController;
  late final TextEditingController categoryController;

  String? selectedWalletId;
  String? receiptUrl;

  // simple entrance animation
  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  // Local modal state managed by Riverpod providers
  static final txnModalSelectedWalletProvider =
      StateProvider<String?>((ref) => null);
  static final txnModalReceiptProvider = StateProvider<String?>((ref) => null);

  @override
  void initState() {
    amountController = TextEditingController();
    noteController = TextEditingController();
    categoryController = TextEditingController();
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    categoryController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<String?> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    return picked?.path;
  }

  Future<String?> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    return result?.files.first.path;
  }

  void showAddEditTransaction([TransactionEntity? transaction]) {
    if (transaction != null) {
      amountController.text = transaction.amount.toString();
      noteController.text = transaction.note;
      categoryController.text = transaction.category;
      // set modal state via providers
      ref.read(txnModalSelectedWalletProvider.notifier).state =
          transaction.walletId;
      ref.read(txnModalReceiptProvider.notifier).state = transaction.receiptUrl;
    } else {
      amountController.clear();
      noteController.clear();
      categoryController.clear();
      ref.read(txnModalSelectedWalletProvider.notifier).state = null;
      ref.read(txnModalReceiptProvider.notifier).state = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Consumer(
          builder: (context, localRef, _) {
            final wallets = localRef.watch(walletProvider);
            final selWallet = localRef.watch(txnModalSelectedWalletProvider);
            final recUrl = localRef.watch(txnModalReceiptProvider);
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: "Amount"),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: "Note"),
                  ),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: "Category"),
                  ),
                  DropdownButtonFormField<String>(
                    value: selWallet,
                    decoration:
                        const InputDecoration(labelText: "Select Wallet"),
                    items: wallets.map((wallet) {
                      return DropdownMenuItem(
                        value: wallet.id,
                        child: Text(wallet.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      localRef
                          .read(txnModalSelectedWalletProvider.notifier)
                          .state = value;
                    },
                  ),
                  Row(
                    children: [
                      const Text("Receipt:"),
                      recUrl != null
                          ? Expanded(
                              child:
                                  Text(recUrl, overflow: TextOverflow.ellipsis))
                          : const SizedBox.shrink(),
                      IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () async {
                          final url = await pickImage();
                          localRef
                              .read(txnModalReceiptProvider.notifier)
                              .state = url;
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: () async {
                          final url = await pickFile();
                          localRef
                              .read(txnModalReceiptProvider.notifier)
                              .state = url;
                        },
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final chosenWallet =
                          localRef.read(txnModalSelectedWalletProvider);
                      if (chosenWallet == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please select a wallet")));
                        return;
                      }
                      // Capture navigator and messenger before async gaps
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      final transactionObj = TransactionEntity(
                        id: transaction?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        amount: double.tryParse(amountController.text) ?? 0,
                        date: DateTime.now(),
                        category: categoryController.text,
                        walletId: chosenWallet,
                        note: noteController.text,
                        receiptUrl: localRef.read(txnModalReceiptProvider),
                        updatedAt: DateTime.now(),
                        isDeleted: false,
                      );
                      final notifier = ref.read(transactionProvider.notifier);
                      try {
                        if (transaction == null) {
                          await notifier.addTransaction(transactionObj);
                        } else {
                          await notifier.editTransaction(transactionObj);
                        }
                        navigator.pop();
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                              content: Text('Failed to save transaction: $e')),
                        );
                      }
                    },
                    child: Text(transaction == null ? "Add" : "Edit"),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final notifier = ref.read(transactionProvider.notifier);

    return ResponsiveScaffold(
      currentIndex: 2,
      onIndexChanged: (idx) {
        switch (idx) {
          case 0:
            context.router.push(const DashboardRoute());
            break;
          case 1:
            context.router.push(const WalletRoute());
            break;
          default:
            break;
        }
      },
      body: SlideTransition(
        position: _slide,
        child: ListView.builder(
          itemCount: transactions.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (ctx, idx) {
            final transaction = transactions[idx];
            return Card(
              color: AppColor.white,
              child: ListTile(
                title: Text(transaction.category),
                subtitle: Text(
                    '₹${transaction.amount} on ${DateFormat('dd-MM-yyyy').format(transaction.date.toLocal())}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppColor.primary,
                        ),
                        tooltip: 'Edit transaction',
                        onPressed: () => showAddEditTransaction(transaction)),
                    IconButton(
                        icon: const Icon(Icons.delete, color: AppColor.primary),
                        tooltip: 'Delete transaction',
                        onPressed: () =>
                            notifier.deleteTransaction(transaction.id)),
                  ],
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Transaction Details'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Amount: ₹${transaction.amount}'),
                        Text('Category: ${transaction.category}'),
                        Text('Wallet: ${transaction.walletId}'),
                        Text('Note: ${transaction.note}'),
                        if (transaction.receiptUrl != null)
                          const Text('Receipt: '),
                        if (transaction.receiptUrl != null)
                          SizedBox(
                            height: 70,
                            width: 70,
                            child: Image.file(
                              File(transaction.receiptUrl ?? ''),
                              fit: BoxFit.fill,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Semantics(
            button: true,
            label: 'Add transaction',
            child: FloatingActionButton(
              heroTag: 'add_transaction',
              child: const Icon(Icons.add),
              onPressed: () => showAddEditTransaction(),
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            button: true,
            label: 'Import transactions from JSON',
            child: FloatingActionButton(
              heroTag: 'import_transaction',
              backgroundColor: Colors.green,
              child: const Icon(Icons.file_upload),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom, allowedExtensions: ['json']);
                if (result != null) {
                  final platformFile = result.files.single;
                  String jsonStr;
                  try {
                    if (platformFile.path != null &&
                        platformFile.path!.isNotEmpty &&
                        !kIsWeb) {
                      // Native platforms: read from file system
                      jsonStr = await File(platformFile.path!).readAsString();
                    } else if (platformFile.bytes != null) {
                      // Web (or when path is unavailable): read from bytes
                      jsonStr = utf8.decode(platformFile.bytes!);
                    } else {
                      messenger.showSnackBar(const SnackBar(
                          content: Text('Unable to read selected file')));
                      return;
                    }

                    final List<dynamic> jsonList = jsonDecode(jsonStr);
                    final transactions = jsonList
                        .map((e) => TransactionEntity(
                              id: e['id'] ??
                                  DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                              amount: (e['amount'] as num?)?.toDouble() ?? 0,
                              date: DateTime.tryParse(e['date'] ?? '') ??
                                  DateTime.now(),
                              category: e['category'] ?? '',
                              walletId: e['walletId'] ?? '',
                              note: e['note'] ?? '',
                              receiptUrl: e['receiptUrl'],
                              isDeleted: e['isDeleted'] ?? false,
                              updatedAt:
                                  DateTime.tryParse(e['updatedAt'] ?? '') ??
                                      DateTime.now(),
                            ))
                        .toList();
                    final controller = ref.read(transactionProvider.notifier);
                    for (final transaction in transactions) {
                      await controller.addTransaction(transaction);
                    }
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text('Transactions imported successfully!')),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Failed to import: $e')),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            button: true,
            label: 'Export transactions to JSON',
            child: FloatingActionButton(
              heroTag: 'export_transaction',
              backgroundColor: Colors.blue,
              child: const Icon(Icons.file_download),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final success =
                      await exportTransactionsAsJson(context, transactions);
                  if (success) {
                    messenger.showSnackBar(const SnackBar(
                        content: Text('Transactions exported successfully')));
                  }
                } catch (e) {
                  messenger.showSnackBar(
                      SnackBar(content: Text('Export failed: $e')));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
