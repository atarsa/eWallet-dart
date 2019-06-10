import 'dart:html';
import 'package:e_wallet/src/item.dart';
import 'package:e_wallet/src/ui.dart';

final UISelectors = getUISelectors();

// passing wallet as needed to update base currency on user input
void loadEventListeners(Wallet wallet){

   // Listen for key up in currency input
   querySelectorAll(UISelectors["currencyInput"])
     .onKeyUp.listen(showCurrencyList);
   
   // Listen for click on currency list item
  querySelectorAll(UISelectors["currencyList"]).onClick.listen
   ((e) => getCurrencyInput(e, wallet));
}

 getCurrencyInput(Event e, Wallet wallet){
  // get targeted element and currency list
  var targetedElem = (e.target as HtmlElement);
  //print(targetedElem);
  var targetedList;
  switch(targetedElem.classes.toString()){
    case 'small':
      // traverse DOM two levels up
      targetedList = targetedElem.parent.parent as HtmlElement;

      // traverse up DOM to get parent of targeted element
      targetedElem = targetedElem.parent;
      continue collectionItem;
      // continue get class: base ? item;
    collectionItem:
    case 'collection-item':
      targetedList = targetedElem.parent as HtmlElement;
      if(targetedList.classes.contains('base')){

        // set base currency user input
        final baseCurrencyInput = querySelector
          (UISelectors["baseCurrencyInput"]) as InputElement;
        baseCurrencyInput.value = targetedElem.text;
        // update base currency in wallet with currency abbreviation only
        wallet.baseCurrency = targetedElem.text.split(" ")[0];
      } else {
        // set item currency user input
        final itemCurrencyInput = querySelector
          (UISelectors["itemCurrencyInput"]) as InputElement;
        itemCurrencyInput.value = targetedElem.text;
      }
      break;
  }
  (targetedList as HtmlElement).innerHtml = '';

}

void main() {

  // initialise wallet
  Wallet wallet = Wallet([], "GBP");

  loadEventListeners(wallet);

}
