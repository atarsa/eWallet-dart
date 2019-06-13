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
      .onKeyUp
      .listen(showCurrencyList);

  //  click on currency list item
  querySelectorAll(UISelectors["currencyList"])
      .onClick
      .listen((Event e) => getCurrencyInput(e, wallet));

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
  querySelector(UISelectors["backBtn"]).onClick.listen((Event e) {
    setDefaultState();
  });

  // clear all click event
  querySelector(UISelectors["clearBtn"]).onClick.listen((Event e) =>
      clearAllClick(e, wallet));
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
      // TODO: remove item from local storage

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
  // TODO: update local storage

  // update UI
  updateListItemUI(updatedItem, w);
  updateTotalMoneyUI(w.baseCurrency);
  clearUserInput();
  setDefaultState();
}

void getCurrencyInput(Event e, Wallet w) {
  // get targeted element and currency list
  var targetedElem = (e.target as HtmlElement);
  //print(targetedElem);
  var targetedList;
  switch (targetedElem.classes.toString()) {
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
      if (targetedList.classes.contains('base')) {
        // set base currency user input
        final baseCurrencyInput =
            querySelector(UISelectors["baseCurrencyInput"]) as InputElement;
        baseCurrencyInput.value = targetedElem.text;
        // update base currency in wallet with currency abbreviation only
        w.baseCurrency = targetedElem.text.split(" ")[0];
        print(w.baseCurrency);
        // TODO: update local storage base currency
        // fetch new currency exchange rates
        fetchCurrencyExchangeRates(w.baseCurrency);
        // update all list items if any
        populateItemsList(w);
        // update total money
        updateTotalMoneyUI(w.baseCurrency);
      } else {
        // set item currency user input
        final itemCurrencyInput =
            querySelector(UISelectors["itemCurrencyInput"]) as InputElement;
        itemCurrencyInput.value = targetedElem.text;
      }
      break;
  }
  (targetedList as HtmlElement).innerHtml = '';
}

clearAllClick(Event e, Wallet wallet){

  if (window.confirm("Are you sure?")){
    // clear items data
    wallet.clearDataItems();
    // TODO: clear local storage

    // clear UI
    clearUserInput();
    clearItemsList();
    updateTotalMoneyUI(wallet.baseCurrency);
    // hide items list as none items left
    toggleItemsListBorder();
  }
}

void main() {
  // initialise wallet
  Wallet wallet = Wallet([], "GBP");
  // default with GBP; TODO: get it from local storage
  // set default base currency input on page load
  String baseCurrency = wallet.baseCurrency;
  String currencyFullName = getCurrencyFullName(baseCurrency);
  (querySelector(UISelectors["baseCurrencyInput"]) as InputElement).value =
      "$baseCurrency $currencyFullName";

  // fetch current exchange currency rates
  fetchCurrencyExchangeRates(baseCurrency);
  //
  setDefaultState();
  // TODO: get list items from local storage
  // populate items list UI
  populateItemsList(wallet);
  // update total converted money
  //updateTotalMoneyUI(baseCurrency);
  toggleItemsListBorder();
  loadEventListeners(wallet);
}
