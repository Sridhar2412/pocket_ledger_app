import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger_app/core/theme/app_color.dart';
import 'package:pocket_ledger_app/domain/models/wallet_model.dart';
import 'package:pocket_ledger_app/presentation/components/responsive_scaffold.dart';
import 'package:pocket_ledger_app/presentation/providers/wallet_provider.dart';
import 'package:pocket_ledger_app/presentation/routes/app_router.gr.dart';

@RoutePage()
class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  final nameController = TextEditingController();
  final balanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletProvider);
    final controller = ref.read(walletProvider.notifier);

    return FadeTransition(
      opacity: _fade,
      child: ResponsiveScaffold(
        currentIndex: 1,
        onIndexChanged: (idx) {
          switch (idx) {
            case 0:
              context.router.push(const DashboardRoute());
              break;
            case 2:
              context.router.push(const TransactionRoute());
              break;
            default:
              break;
          }
        },
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: wallets.length,
          itemBuilder: (ctx, idx) {
            final wallet = wallets[idx];
            return Semantics(
              container: true,
              label: 'Wallet ${wallet.name}, balance ${wallet.balance}',
              child: Card(
                color: AppColor.white,
                child: ListTile(
                  title: Text(wallet.name),
                  subtitle:
                      Text('Balance: ₹${wallet.balance.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppColor.primary,
                        ),
                        tooltip: 'Edit wallet',
                        onPressed: () {
                          nameController.text = wallet.name;
                          balanceController.text = wallet.balance.toString();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            builder: (context) => Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                                top: 16,
                                left: 16,
                                right: 16,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text('Edit Wallet',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge),
                                      const SizedBox(height: 12),
                                      TextField(
                                          controller: nameController,
                                          decoration: const InputDecoration(
                                              labelText: 'Name')),
                                      const SizedBox(height: 8),
                                      TextField(
                                          controller: balanceController,
                                          decoration: const InputDecoration(
                                              labelText: 'Balance'),
                                          keyboardType: TextInputType.number),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                        ),
                                        onPressed: () async {
                                          final navigator =
                                              Navigator.of(context);
                                          final messenger =
                                              ScaffoldMessenger.of(context);
                                          try {
                                            await controller.editWallet(
                                              WalletModel(
                                                id: wallet.id,
                                                name: nameController.text,
                                                balance: double.tryParse(
                                                        balanceController
                                                            .text) ??
                                                    wallet.balance,
                                                updatedAt: wallet.updatedAt,
                                              ),
                                            );
                                            navigator.pop();
                                          } catch (e) {
                                            messenger.showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Failed to save wallet: $e')),
                                            );
                                          }
                                        },
                                        child: const Text('Save'),
                                      ),
                                      const SizedBox(height: 8),
                                    ]),
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppColor.primary,
                        ),
                        tooltip: 'Delete wallet',
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await controller.deleteWallet(wallet.id);
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                  content: Text('Failed to delete wallet: $e')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: Semantics(
          button: true,
          label: 'Add wallet',
          child: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              nameController.clear();
              balanceController.clear();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    top: 16,
                    left: 16,
                    right: 16,
                  ),
                  child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('Add Wallet',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Name')),
                      const SizedBox(height: 8),
                      TextField(
                          controller: balanceController,
                          decoration:
                              const InputDecoration(labelText: 'Balance'),
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await controller.addWallet(WalletModel(
                              updatedAt: DateTime.now(),
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              name: nameController.text,
                              balance:
                                  double.tryParse(balanceController.text) ?? 0,
                            ));
                            navigator.pop();
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                  content: Text('Failed to add wallet: $e')),
                            );
                          }
                        },
                        child: const Text('Add'),
                      ),
                      const SizedBox(height: 8),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
