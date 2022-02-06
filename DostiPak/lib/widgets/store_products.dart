import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rishtpak/constants/constants.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/models/app_model.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/widgets/my_circular_progress.dart';
import 'package:scoped_model/scoped_model.dart';

class StoreProducts extends StatefulWidget {
  final Widget icon;
  final Color priceColor;

  StoreProducts({required this.icon, required this.priceColor});

  @override
  _StoreProductsState createState() => _StoreProductsState();
}

class _StoreProductsState extends State<StoreProducts> {
  // Variables
  bool _storeIsAvailable = false;
  List<ProductDetails>? _products;
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();

    // if(mounted)
    //   setState(() {});

    // Check google play services
    InAppPurchaseConnection.instance.isAvailable().then((result) {
      if (mounted)
        setState(() {
          _storeIsAvailable = result; // if false the store can not be reached or accessed
        });
    });

    // Get product subscriptions from google play store / apple store
    debugPrint('test_product_id: ${AppModel().appInfo.subscriptionIds}');
    InAppPurchaseConnection.instance
        .queryProductDetails(AppModel().appInfo.subscriptionIds.toSet())   //AppModel().appInfo.subscriptionIds.toSet()   //['android.test.purchased'].toSet()
        .then((ProductDetailsResponse response) async {

          debugPrint('notFoundIDS: ${response.notFoundIDs}');

          /// Update UI
          if (mounted){
            // Get product list
            await Future.delayed(Duration(seconds: 1));
            print('size_list1: ${response.productDetails.length}');
            _products = response.productDetails;

            setState(() {});

            // Check result
            // if(_products!.isNotEmpty){
            //   InAppPurchaseConnection.instance
            //       .queryProductDetails(['android.test.purchased'].toSet())
            //       .then((ProductDetailsResponse res) async {
            //
            //     print('size_list2: ${res.productDetails.length}');
            //     if(mounted){
            //       // await Future.delayed(Duration(seconds: 2));
            //       _products!.addAll(res.productDetails);
            //       await Future.delayed(Duration(seconds: 2));
            //       _products!.add(res.productDetails.last);
            //
            //       setState(() {});
            //     }
            //   });
            // }

          }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Init
    _i18n = AppLocalizations.of(context);

    return _storeIsAvailable ? _showProducts() : _storeNotAvailable();
  }

  Widget _showProducts() {
    if (_products == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MyCircularProgress(),
              SizedBox(height: 5),
              Text(_i18n.translate("processing"),
                  style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
              Text(_i18n.translate("please_wait"),
                  style: TextStyle(fontSize: 18), textAlign: TextAlign.center)
            ],
          ),
        ),
      );
    }
    else if (_products!.isNotEmpty) {
      // Show Subscriptions
      return ScopedModelDescendant<UserModel>(
          builder: (context, child, userModel) {
        return Column(
            children: _products!.asMap().map((index ,item) {

          // int index = indexProduct;
          // print('index product is ${index}');
          // print('title product is ${productTitles[indexProduct]}');

          return MapEntry(
            index,
            Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              // enabled: userModel.activeVipId == item.id ? false : true,
              leading: widget.icon,
              title: _titleProduct(productTitles[index]),
              //title: Text(
              //                   item.title,
              //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
              subtitle: Text(
                  item.price,
                  style: TextStyle(
                      fontSize: 19,
                      color: widget.priceColor,
                      fontWeight: FontWeight.bold)),
              trailing: ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(8)),
                      backgroundColor: MaterialStateProperty.all<Color>(widget.priceColor),
                      //userModel.activeVipId == item.id
                      //                               ? Colors.grey
                      //                               : widget.priceColor),
                      shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),))),

                  child: Text(_i18n.translate("ACTIVE"), style: TextStyle(color: Colors.white)),
                  //child: userModel.activeVipId == item.id
                  //
                  //                       ? Text(_i18n.translate("ACTIVE"),
                  //                           style: TextStyle(color: Colors.white))
                  //
                  //                       : Text(_i18n.translate("SUBSCRIBE"),
                  //                           style: TextStyle(color: Colors.white)),


                  onPressed: () async {

                    // Purchase parameters
                    final pParam = PurchaseParam(
                      productDetails: item,
                    );

                    /// Subscribe
                    InAppPurchaseConnection.instance
                        .buyConsumable(purchaseParam: pParam).then((isSent) async{

                      //Fill Wallet
                      if(isSent){
                        print('sent');

                        Stream<List<PurchaseDetails>> stream = InAppPurchaseConnection.instance.purchaseUpdatedStream;
                        stream.listen((List<PurchaseDetails> purchaseDetailsList) async {

                          print('listening');
                          print('Purchase_product_id: ${purchaseDetailsList.last.productID}');
                          print('product_product_id: ${item.id}');
                          print('is_same: ${purchaseDetailsList.last.productID == item.id}');

                          PurchaseDetails lastPurchase = purchaseDetailsList.last;

                          var result = await InAppPurchaseConnection.instance.completePurchase(lastPurchase);
                          if (result.responseCode != BillingResponse.ok) {
                            print("error_result: ${result.responseCode} (${result.debugMessage})");
                          }
                          else{
                            print('success_result: ${result.responseCode}');

                            _fillGoldsWallet(index).then((value){
                              print('wallet is updated');
                              stream.drain();
                            });

                          }

                        });

                      }
                      else {
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          // false = user must tap button, true = tap outside dialog
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: Text('ERROR'),
                              content: Text('Your request is failed , try again'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(dialogContext)
                                        .pop(); // Dismiss alert dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }

                    });
                  }

                // onPressed: userModel.activeVipId == item.id
                //               ? null
                //                   : () async {.................}
              ),
            ),
          ),
          );
        }).values.toList());
      });
    }
    else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.search,
                  size: 80, color: Theme.of(context).primaryColor),
              Text(_i18n.translate("no_products_or_subscriptions"),
                  style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _fillGoldsWallet(int index) async{
     UserModel().getUser(UserModel().user.userId).then((snapshot) {

      print('index: $index');

      Map<String,dynamic> data =  snapshot.data()!;

      if(index == 0)
        data[USER_WALLET] = data[USER_WALLET] + 800;
      else if(index == 1)
        data[USER_WALLET] = data[USER_WALLET] + 1600;
      else if(index == 2)
        data[USER_WALLET] = data[USER_WALLET] + 3200;
      else if(index == 3)
        data[USER_WALLET] = data[USER_WALLET] + 6400;
      else
        data[USER_WALLET] = 1000000000000000000;

      print('data_wallet: ${data[USER_WALLET]}');

      //Submit changes
      FirebaseFirestore.instance.collection(C_USERS).doc(UserModel().user.userId).update(data).then((value){

        //Show dialog
        // showDialog<void>(
        //   context: context,
        //   barrierDismissible: false,
        //   // false = user must tap button, true = tap outside dialog
        //   builder: (BuildContext dialogContext) {
        //     return AlertDialog(
        //       title: Text('SUCCESS'),
        //       content: Text('Your request is sent successfully , check your wallet in settings screen'),
        //       actions: <Widget>[
        //         FlatButton(
        //           child: Text('OK'),
        //           onPressed: () {
        //             Navigator.of(dialogContext)
        //                 .pop(); // Dismiss alert dialog
        //           },
        //         ),
        //       ],
        //     );
        //   },
        // );


      });
    });
  }

  Widget _storeNotAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.error_outline,
              size: 80, color: Theme.of(context).primaryColor),
          Text(_i18n.translate("oops_an_error_has_occurred"),
              style: TextStyle(fontSize: 18.0), textAlign: TextAlign.center),
        ],
      ),
    );
  }


  ///NEW
  int indexProduct = 0;
  List<String> productTitles = [
    "Buy 800 Golds for 500 PKR",
    "Buy 1600 Golds for 1000 PKR",
    "Buy 3200 Golds for 2000 PKR",
    "Buy 6400 Golds for 3900 PKR",
    "Buy Unlimited Golds for 8500 PKR",
  ];

  Widget _titleProduct(String productTitle) {

    if(indexProduct <= _products!.length - 1)
      indexProduct++;
    else
      indexProduct = 0;

    return Text(
        productTitle,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }
}
