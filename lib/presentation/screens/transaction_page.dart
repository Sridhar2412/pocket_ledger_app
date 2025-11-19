import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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

  void showAddEditTransaction([TransactionEntity? txn]) {
    if (txn != null) {
      amountController.text = txn.amount.toString();
      noteController.text = txn.note;
      categoryController.text = txn.category;
      selectedWalletId = txn.walletId;
      receiptUrl = txn.receiptUrl;
    } else {
      amountController.clear();
      noteController.clear();
      categoryController.clear();
      selectedWalletId = null;
      receiptUrl = null;
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
        child: StatefulBuilder(
          builder: (context, setState) {
            final wallets = ref.read(walletProvider);
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
                    value: selectedWalletId,
                    decoration:
                        const InputDecoration(labelText: "Select Wallet"),
                    items: wallets.map((wallet) {
                      return DropdownMenuItem(
                        value: wallet.id,
                        child: Text(wallet.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedWalletId = value;
                      });
                    },
                  ),
                  Row(
                    children: [
                      const Text("Receipt:"),
                      receiptUrl != null
                          ? Expanded(
                              child: Text(receiptUrl!,
                                  overflow: TextOverflow.ellipsis))
                          : const SizedBox.shrink(),
                      IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () async {
                          final url = await pickImage();
                          setState(() => receiptUrl = url);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: () async {
                          final url = await pickFile();
                          setState(() => receiptUrl = url);
                        },
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedWalletId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please select a wallet")));
                        return;
                      }
                      final txnObj = TransactionEntity(
                        id: txn?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        amount: double.tryParse(amountController.text) ?? 0,
                        date: DateTime.now(),
                        category: categoryController.text,
                        walletId: selectedWalletId!,
                        note: noteController.text,
                        receiptUrl: receiptUrl,
                        updatedAt: DateTime.now(),
                        isDeleted: false,
                      );
                      final controller = ref.read(transactionProvider.notifier);
                      try {
                        if (txn == null) {
                          await controller.addTransaction(txnObj);
                        } else {
                          await controller.editTransaction(txnObj);
                        }
                        if (mounted) Navigator.pop(context);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Failed to save transaction: $e')),
                          );
                        }
                      }
                    },
                    child: Text(txn == null ? "Add" : "Edit"),
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
    final txns = ref.watch(transactionProvider);
    final controller = ref.read(transactionProvider.notifier);

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
          itemCount: txns.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (ctx, idx) {
            final txn = txns[idx];
            return Card(
              child: ListTile(
                title: Text(txn.category),
                subtitle: Text('₹${txn.amount} on ${txn.date.toLocal()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit transaction',
                        onPressed: () => showAddEditTransaction(txn)),
                    IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete transaction',
                        onPressed: () => controller.deleteTransaction(txn.id)),
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
                        Text('Amount: ₹${txn.amount}'),
                        Text('Category: ${txn.category}'),
                        Text('Wallet: ${txn.walletId}'),
                        Text('Note: ${txn.note}'),
                        if (txn.receiptUrl != null)
                          Text('Receipt: ${txn.receiptUrl}'),
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
              heroTag: 'add_txn',
              child: const Icon(Icons.add),
              onPressed: () => showAddEditTransaction(),
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            button: true,
            label: 'Import transactions from JSON',
            child: FloatingActionButton(
              heroTag: 'import_txn',
              backgroundColor: Colors.green,
              child: const Icon(Icons.file_upload),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom, allowedExtensions: ['json']);
                if (result != null && result.files.single.path != null) {
                  final path = result.files.single.path!;
                  try {
                    final jsonStr = await File(path).readAsString();
                    final List<dynamic> jsonList = jsonDecode(jsonStr);
                    final txns = jsonList
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
                    for (final txn in txns) {
                      await controller.addTransaction(txn);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Transactions imported successfully!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to import: $e')),
                      );
                    }
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
