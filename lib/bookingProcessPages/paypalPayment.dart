// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';

import '../main.dart';

class PayPalPagmentPage extends StatefulWidget {
  const PayPalPagmentPage({Key? key, required this.title, required this.value})
      : super(key: key);
  final String title;
  final double value;

  @override
  State<PayPalPagmentPage> createState() => _PayPalPagmentPageState();
}

class _PayPalPagmentPageState extends State<PayPalPagmentPage> {
  get value => widget.value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: TextButton(
              onPressed: () => {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => UsePaypal(
                            sandboxMode: false,
                            clientId:
                                "ASmPIumSBTCKYMz-it7f2EzYTM-9YMxZ8RzuEWHS_uWdb7uf30ecJWLjd60rZMTF8xa7R2ON02Owk1Yb",
                            secretKey:
                                "EEHf12h9tHzYvMGfhiOrLiN__-rkx6c9Oi5lVtx_2EbYogqGQ30pPEKQq5PLISUiNU5qYZztMPG1JUem",
                            returnURL: "https://google.com",
                            cancelURL: "https://google.com",
                            transactions: [
                              {
                                "amount": {
                                  "total": value,
                                  "currency": "EUR",
                                  "details": {
                                    "subtotal": value,
                                    "shipping": '0',
                                    "shipping_discount": 0
                                  }
                                },
                                "description":
                                    "The payment transaction description.",
                                "item_list": {
                                  "items": [
                                    {
                                      "name": "Parking spot payment",
                                      "quantity": 1,
                                      "price": value,
                                      "currency": "EUR"
                                    }
                                  ],
                                }
                              }
                            ],
                            note: "Contact us for any questions on your order.",
                            onSuccess: (Map params) async {
                              print("onSuccess: $params");
                              navigatorKey.currentState
                                  ?.pushReplacementNamed('/history');
                            },
                            onError: (error) {
                              print("onError: $error");
                              navigatorKey.currentState
                                  ?.pushReplacementNamed('/history');
                            },
                            onCancel: (params) {
                              print('cancelled: $params');
                              navigatorKey.currentState
                                  ?.pushReplacementNamed('/history');
                            }),
                      ),
                    )
                  },
              child: const Text("Make Payment")),
        ));
  }
}
