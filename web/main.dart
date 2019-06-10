import 'dart:html';
import 'package:e_wallet/src/item.dart';
import 'package:e_wallet/src/ui.dart';

final UISelectors = getUISelectors();

void loadEventListeners(){

  // Listen for key up in currency input

 querySelectorAll(UISelectors["currencyInput"])
     .onKeyUp.listen(showCurrencyList);
}


void main() {

// initialise wallet
Wallet wallet = Wallet([], "GBP");

loadEventListeners();




}
