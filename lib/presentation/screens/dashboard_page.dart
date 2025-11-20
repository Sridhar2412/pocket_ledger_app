import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger_app/core/sync/sync_service.dart';
import 'package:pocket_ledger_app/presentation/components/category_chart.dart';
import 'package:pocket_ledger_app/presentation/components/monthly_chart.dart';
import 'package:pocket_ledger_app/presentation/components/responsive_scaffold.dart';
import 'package:pocket_ledger_app/presentation/providers/transaction_provider.dart';
import 'package:pocket_ledger_app/presentation/providers/wallet_provider.dart';
import 'package:pocket_ledger_app/presentation/routes/app_router.gr.dart';

@RoutePage()
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletProvider);
    final transactionList = ref.watch(transactionProvider);
    final incomeData = List<double>.filled(12, 0);
    final expenseData = List<double>.filled(12, 0);
    final categoryTotals = <String, double>{};

    for (final transaction in transactionList) {
      final month = transaction.date.month - 1;
      if (transaction.amount >= 0) {
        incomeData[month] += transaction.amount;
      } else {
        expenseData[month] += transaction.amount.abs();
      }
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) +
              transaction.amount.abs();
    }

    return ResponsiveScaffold(
      currentIndex: 0,
      onIndexChanged: (idx) {
        switch (idx) {
          case 1:
            context.router.push(const WalletRoute());
            break;
          case 2:
            context.router.push(const TransactionRoute());
            break;
          default:
            // already on dashboard
            break;
        }
      },
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isWide ? 32.0 : 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  child: Card(
                    color: Colors.blue.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text("Wallets Overview",
                              style: Theme.of(context).textTheme.titleLarge),
                          Text(
                              "Total: ₹${wallets.fold(0, (s, w) => s + w.balance.toInt()).toStringAsFixed(2)}"),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Monthly Income vs Expenses"),
                const SizedBox(height: 20),
                SizedBox(
                    child: MonthlyBarChart(
                        incomeData: incomeData, expenseData: expenseData)),
                const SizedBox(height: 24),
                const Text("Category Breakdown"),
                SizedBox(
                    height: 230,
                    child: CategoryPieChart(categoryTotals: categoryTotals)),
                const SizedBox(height: 24),
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Income: ₹${incomeData.reduce((a, b) => a + b).toStringAsFixed(2)}"),
                        Text(
                            "Expense: ₹${expenseData.reduce((a, b) => a + b).toStringAsFixed(2)}"),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // call the SyncService to perform offline sync
                    final sync = ref.read(syncServiceProvider);
                    final ok = await sync.performFullSync();
                    if (ok) {
                      // refresh local state
                      await ref.read(walletProvider.notifier).loadWallets();
                      await ref
                          .read(transactionProvider.notifier)
                          .loadTransactions();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sync completed')));
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Sync failed — retry later')));
                      }
                    }
                  },
                  child: const Text('Sync Now'),
                ),
                const SizedBox(height: 18),
                // navigation moved to bottom navigation bar
              ],
            ),
          ),
        );
      }),
    );
  }
}
