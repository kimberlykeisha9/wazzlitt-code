import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app.dart';

class ServiceOverview extends StatefulWidget {
  const ServiceOverview({super.key, required this.service});

  final Map<String, dynamic> service;

  @override
  State<ServiceOverview> createState() => _ServiceOverviewState();
}

class _ServiceOverviewState extends State<ServiceOverview> {
  DateTime period = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        period = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service['service_name']),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      image: widget.service['image'] == null ? null : DecorationImage(image: NetworkImage(
                          widget.service['image']
                      ), fit: BoxFit.cover)
                  ),
                ),
                const SizedBox(height: 20),
                Text(widget.service['service_name'], style: const TextStyle(fontWeight: FontWeight
                    .bold, fontSize: 20)),
                const SizedBox(height: 10),
                Text(widget.service['service_description']),
                const SizedBox(height: 10),
                Text('\$${(widget.service['price'] as double).toStringAsFixed(2)}'),
                const SizedBox(height: 20),
                    const Text('Overview',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Total Gross Sales', style: TextStyle
                          (fontWeight: FontWeight.bold)), Text('\$0.00',
                        )]),
                    const SizedBox(height: 5),
                    const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Units Sold', style: TextStyle
                          (fontWeight: FontWeight.bold)),
                          Text
                          ('0')]),
                    const SizedBox(height: 10),
                const Text('Sales History',
                    style: TextStyle(fontWeight: FontWeight.bold)),

                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(DateFormat.yMMMM().format(period),
                        style:
                    const TextStyle
                      (fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: const Text
                          ('Choose Month'),
                      )]),

                const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('Sales of Period', style: TextStyle
                      (fontWeight: FontWeight.bold)),
                      Text
                        ('\$ 0.00')]),
                const SizedBox(height: 20),
                const Text('Last 5 Transactions',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Expanded(
                flex: 2,
                        child: Text('Date', style: TextStyle(fontWeight:
                        FontWeight.bold, fontSize: 12)),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                        flex: 3,
                      child: Text('Transaction ID', style: TextStyle(fontWeight:
                      FontWeight.bold, fontSize: 12)),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text('Quantity', style: TextStyle(fontWeight:
                      FontWeight.bold, fontSize: 12), textAlign: TextAlign
                          .right),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text('Amount', style: TextStyle(fontWeight:
                      FontWeight.bold, fontSize: 12), textAlign: TextAlign
                          .right),
                    ),
                  ]
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  itemCount: 5,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => Container(
                    height: 40,
                      width: width(context),
                      alignment: Alignment.center,
                    child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                    flex: 2,
                            child: Text('01/Jan/2023', style: TextStyle(fontSize:
                            14)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text('ABCD-EFGH-IJKL', style: TextStyle
                              ( fontSize: 14)),
                          ),
                          Expanded(
                            child: Text('0', style: TextStyle(fontSize: 14), textAlign: TextAlign.right),
                          ),
                          Expanded(
                            child: Text('\$ 0.00', style: TextStyle(fontSize: 14), textAlign: TextAlign.right),
                          ),
                        ]
                    ),
                    )
                  ),
              ],
            ),
          ),
        )
      ),
    );
  }
}
