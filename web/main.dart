import 'dart:html';
import 'package:e_wallet/src/item.dart';
import 'package:e_wallet/src/ui.dart';

final UISelectors = getUISelectors();

// passing wallet as a parameter to have access to wallet's data items
void loadEventListeners(Wallet wallet) {
  // disable form submit on enter
  querySelector("body").onKeyUp.listen((KeyboardEvent e) {
    if (e.keyCode == KeyCode.ENTER) {
      e.preventDefault();
    }
  });

  //  key up in currency input
  querySelectorAll(UISelectors["currencyInput"])
     .onKeyUp.listen(showCurrencyList);
   
   //  click on currency list item
  querySelectorAll(UISelectors["currencyList"]).onClick.listen
   ((Event e) => getCurrencyInput(e, wallet));

  // add item event
  querySelector(UISelectors["addBtn"]).onClick.listen((Event e)
  => addItemSubmit(e, wallet));
}

addItemSubmit(Event e, Wallet wallet){
  // get user input
  List input = getItemInput();
  String currency = input[0];
  double amount = num.parse(input[1]);

  // check for currency and amount input
  if(currency != '' && amount != null){
    // check if number is positive
    if (amount < 0){
      // TODO: show alert
      // showAlert("Amount must be positive");
    } else {
      // get currency abbreviation
      currency = currency.split(" ")[0];

      // check if currency already in items list
      // -> if yes update it instead of creating new item
      final dataItems = wallet.itemsList;

      // if items list empty than add new item
      if (dataItems.isEmpty){
        Item newItem = wallet.addItem(currency, amount);
        // update UI
        addListItemUI(newItem, wallet);
      } else {
        // check if currency already on the list
       Item found = dataItems.singleWhere( (item) => item.currency ==
           currency, orElse: () => null);

        // update list item
        if (found != null){
          found.amount += amount;
          updateListItemUI(found, wallet);
        } else {
          // add new item to the list
          Item newItem = wallet.addItem(currency, amount);
          addListItemUI(newItem, wallet);
        }

      }

      clearUserInput();

    }

  } else {
    // TODO: show message that no input
    // showAlert("Please fill the form");
  }
  e.preventDefault();
}

void getCurrencyInput(Event e, Wallet wallet){
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
  // default with GBP; TODO: get it from local storage

  loadEventListeners(wallet);

}
