import 'dart:html';
import 'package:e_wallet/src/item.dart';
import 'package:e_wallet/src/ui.dart';
import 'package:e_wallet/src/storage.dart';

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
      .onKeyUp
      .listen(showCurrencyList);

  //  click on currency list item
  querySelectorAll(UISelectors["currencyList"])
      .onClick
      .listen((Event e) => getCurrencyInput(e, wallet));

  // click on base currency dropdown list
  querySelector(UISelectors["baseCurrencyList"])
      .onClick
      .listen((Event e) => pickBaseCurrency(e, wallet));

  // add item submit event
  querySelector(UISelectors["addBtn"])
      .onClick
      .listen((Event e) => addItemSubmit(e, wallet));

  // delete item submit event
  querySelector(UISelectors["itemsList"])
      .onClick
      .listen((Event e) => deleteItemSubmit(e, wallet));

  // edit item click event
  querySelector(UISelectors["itemsList"])
      .onClick
      .listen((Event e) => editItemClick(e, wallet));

  // update item submit event
  querySelector(UISelectors["updateBtn"])
      .onClick
      .listen((Event e) => updateItemSubmit(e, wallet));

  // back button click event
  querySelector(UISelectors["backBtn"])
      .onClick
      .listen((Event e) => setDefaultState());

  // clear all click event
  querySelector(UISelectors["clearBtn"])
      .onClick
      .listen((Event e) => clearAllClick(e, wallet));
}

void addItemSubmit(Event e, Wallet wallet) {
  // get user input
  List input = getItemInput();

  if (input[0] != '' && input[1] != null){
    String currency = input[0];
    double amount = num.parse(input[1]);

    if (amount < 0) {
      showAlert("Amount must be positive");
    } else {
      // validate currency input
      if (isCurrencyValid(currency)){

        // get currency abbreviation
        currency = currency.split(" ")[0];

        // check if currency already in items list
        // -> if yes update it instead of creating new item
        final dataItems = wallet.itemsList;

        // if items list empty than add new item
        if (dataItems.isEmpty) {
          Item newItem = wallet.addItem(currency, amount);
          // update UI
          addListItemUI(newItem, wallet);
        } else {
          // check if currency already on the list
          Item found = dataItems.singleWhere((item) => item.currency == currency,
              orElse: () => null);

          // update list item
          if (found != null) {
            found.amount += amount;
            updateListItemUI(found, wallet);
          } else {
            // add new item to the list
            Item newItem = wallet.addItem(currency, amount);
            addListItemUI(newItem, wallet);
          }
        }
        updateTotalMoneyUI(wallet.baseCurrency);
      } else {
        showAlert('"$currency" is not a valid currency. Please try again.');
      }
      clearUserInput();
    }
  } else {
    showAlert("Please fill the form");
  }
  e.preventDefault();
}

void deleteItemSubmit(Event e, Wallet w) {
  final elem = e.target as HtmlElement;
  if (elem.classes.contains('delete-item')) {
    // get item id
    int elemId = num.parse(elem.parent.parent.getAttribute('data-id'));

    if (window.confirm("Are you sure?")) {
      // remove item from wallet's items list
      w.deleteItem(elemId);
      // remove item from local storage
      removeItemFromStorage(elemId);
      // remove item from items list UI
      deleteListItemUI(elemId.toString());
      // update total money
      updateTotalMoneyUI(w.baseCurrency);
    }
  }
}

void editItemClick(Event e, Wallet w) {
  final elem = e.target as HtmlElement;

  if (elem.classes.contains('edit-item')) {
    // get item id
    int elemId = num.parse(elem.parent.parent.getAttribute('data-id'));
    // get item
    Item editedItem = w.getItemById(elemId);
    // set item as a current item
    w.setCurrentItem(editedItem);
    // update form with edited item
    addToForm(editedItem);
  }
}

void updateItemSubmit(Event e, Wallet w) {
  List item = getItemInput(); // item[0] => currency,item[1] => amount
  // get only abbreviation from currency input
  String currency = item[0].split(" ")[0];
  double amount = num.parse(item[1]);

  // update current item
  Item updatedItem = w.updateItem(currency, amount);
  // update local storage
  updateItemInStorage(updatedItem);

  // update UI
  updateListItemUI(updatedItem, w);
  updateTotalMoneyUI(w.baseCurrency);
  clearUserInput();
  setDefaultState();
}

// Change base currency on item click
void pickBaseCurrency(Event e, Wallet w){
  var baseCurrency;
  final elem = e.target as Element;
  // if 'click' on flag
  if (elem.matches('.flag-icon')){
    // get parent element
    baseCurrency = elem.parent.dataset['currency'];
  } else {
    baseCurrency = elem.dataset['currency'];
  }
  // update base currency in wallet
  w.baseCurrency = baseCurrency;
  // update base currency in local storage
  addBaseCurrencyToStorage(baseCurrency);
  // update base currency button with new base currency and country flag
  updateBaseCurrencyBtn(baseCurrency);
  // update UI
  updateUI(w);
}

void getCurrencyInput(Event e, Wallet w) {
  // get targeted element and currency list
  var elem = (e.target as HtmlElement);

  var targetedList;
  // Check what element targeted to traverse DOM accordingly
  if (elem.matches('.small') || elem.matches('.flag-icon')) {
    // traverse DOM two levels up
    targetedList = elem.parent.parent as HtmlElement;
    // traverse up DOM to get parent of targeted element
    elem = elem.parent;
    } else {
      // traverse DOM one level up
      targetedList = elem.parent as HtmlElement;
    }
    // set item currency user input
    final itemCurrencyInput =
    querySelector(UISelectors["itemCurrencyInput"]) as InputElement;

    itemCurrencyInput.value = elem.text.trim();
    (targetedList as HtmlElement).innerHtml = '';
}

clearAllClick(Event e, Wallet wallet){

  if (window.confirm("Are you sure?")){
    // clear items data
    wallet.clearDataItems();
    // clear local storage
    clearAllStorage();
    // set base currency to GBP as default
    wallet.baseCurrency = 'GBP';
    // clear UI
    clearUserInput();
    clearItemsList();
    updateTotalMoneyUI(wallet.baseCurrency);
    updateBaseCurrencyBtn(wallet.baseCurrency);
  }
}

void main() {
  // set initial state
  setDefaultState();
  // initialise wallet
  Wallet wallet = Wallet(getItemsFromStorage(), getBaseCurrencyFromStorage());

  // set default base currency btn on page load
  updateBaseCurrencyBtn(wallet.baseCurrency);
  updateUI(wallet);
  loadEventListeners(wallet);
}
