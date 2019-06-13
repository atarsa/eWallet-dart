import 'dart:html';
import 'dart:async';
import 'package:e_wallet/src/item.dart';

// define UI Selectors
final _UISelectors = {
  'itemCurrencyInput': '#item-currency',
  'baseCurrencyInput': '#base-currency',
  'currencyInput': '.currency-input',
  'itemAmountInput': '#item-amount',
  'itemsList': '#items-list',
  'listItems': '#items-list li',
  'currencyListItem': '.currency-list.item',
  'currencyListBase': '.currency-list.base',
  'currencyList': '.currency-list',
  'convertedAmount': '.converted-amount',
  // total
  'totalAmount': 'h4 .total-money',
  'totalCurrency': 'h4 .base-currency',
  // buttons
  'addBtn': '.add-btn',
  'updateBtn': '.update-btn',
  'backBtn': '.back-btn',
  'clearBtn': '.clear-btn'
};

// get UI Selectors
Map<String, String> getUISelectors(){
  return _UISelectors;
}

// get user input from item form
List getItemInput(){
  String currency = (querySelector(_UISelectors["itemCurrencyInput"]) as
  InputElement).value;
  
  String amount = (querySelector(_UISelectors["itemAmountInput"])
  as InputElement).value;

  return [currency, amount];
}

// add new item to existing list (UI)
void addListItemUI(Item listItem, Wallet wallet){
  // get base currency, and exchange money
  String baseCurrency = wallet.baseCurrency;
  String convertedAmount = exchangeMoney(listItem.currency, listItem.amount);

  // Create list element
  final li = LIElement();
  // add class and data attribute
  li.className = 'collection-item';
  li.setAttribute('data-id', listItem.id.toString());

  // add html
  li.innerHtml = '''
        <a href="#" class="delete">
          <i class="delete-item fas fa-trash-alt"></i>
        </a>
        <a href="#" class="update">
          <i class="edit-item fas fa-edit"></i>
        </a>
        
        <span class="amount">${listItem.amount}</span>
        <span class="currency">${listItem.currency}</span>
       
        <span class="secondary-content">
          <span class="converted-amount">$convertedAmount</span>
          <span class="base-currency">$baseCurrency</span>
        </span>
  ''';
  // Insert element
  querySelector(_UISelectors["itemsList"]).insertAdjacentElement('beforeend',
      li);

  // check if items list previously empty
  toggleItemsListBorder();
}

void updateListItemUI(Item item, Wallet wallet){
  // get base currency and exchange money
  String baseCurrency = wallet.baseCurrency;
  String convertedAmount = exchangeMoney(item.currency, item.amount);

  (querySelector("[data-id='${item.id}']") as HtmlElement).innerHtml = '''
    <a href="#" class="delete">
        <i class="delete-item fas fa-trash-alt"></i>
      </a>
      <a href="#" class="update">
        <i class="edit-item fas fa-edit"></i>
      </a>
      <span class="amount">${item.amount}</span>
      <span class="currency">${item.currency}</span>
      
      <span class="secondary-content">
        <span class="converted-amount">$convertedAmount</span>
        <span class="base-currency">$baseCurrency</span>
      </span>
   ''';
}

// populate items list
void populateItemsList(Wallet wallet){
  List<Item> itemsList = wallet.itemsList;
  // clear existing list
  (querySelector(_UISelectors["itemsList"]) as UListElement).innerHtml = '';

  // add new li element for each item in wallet
  for (var item in itemsList){
    addListItemUI(item, wallet);
  }
}
// clear items list
void clearItemsList(){
  (querySelector(_UISelectors["itemsList"]) as UListElement).innerHtml = '';
}

void updateTotalMoneyUI(String baseCurrency){
  // get exchanged amount from each item list and calculate total money
  double total = 0;

  final convertedAmounts = querySelectorAll
    (_UISelectors["convertedAmount"]);
  for (var element in convertedAmounts){
    element = (element as HtmlElement);
    double amount = num.parse(element.text);
    total += amount;
  }
  // update UI
  (querySelector(_UISelectors["totalAmount"]) as HtmlElement).text = total
      .toStringAsFixed(2);
  (querySelector(_UISelectors["totalCurrency"]) as HtmlElement).text =
      baseCurrency;
}

void deleteListItemUI(String id){
  (querySelector('[data-id="$id"]') as HtmlElement).remove();
  // check if any list item left
  toggleItemsListBorder();
}

// add edited item to form
void addToForm(Item editedItem){
  String currencyFullName = getCurrencyFullName(editedItem.currency);

  final currencyInput = (querySelector(_UISelectors["itemCurrencyInput"]) as
  InputElement);
  currencyInput.value = "${editedItem.currency} $currencyFullName";
  // disable currency input to prevent multiple
  // same currencies in (currency) list items
  currencyInput.disabled = true;
  (querySelector(_UISelectors["itemAmountInput"]) as InputElement).value =
      editedItem.amount.toString();

  setEditState();
}

// show list of available currencies on user input change
void showCurrencyList(Event e){
  Map<String, String> availableCurrency = getCurrencyList();
  final clickedElem = e.target as HtmlElement;

  UListElement currencyList;
  String currencyInput;

  // get classes of clicked element
  if(clickedElem.classes.contains('base')){
    // base currency input
    currencyList = querySelector(_UISelectors["currencyListBase"]);
    currencyInput = (querySelector(_UISelectors["baseCurrencyInput"]) as
    InputElement).value;
  } else {
    // item currency input
    currencyList = querySelector(_UISelectors["currencyListItem"]);
    currencyInput = (querySelector(_UISelectors["itemCurrencyInput"]) as
    InputElement).value;
  }
  // clear list on each key up
  currencyList.innerHtml = '';

  String ulHTML = '';
  // filter currency with user input
  for (MapEntry<String, String> currency in availableCurrency
      .entries ){
    if (currency.key.toLowerCase().contains(currencyInput.toLowerCase()) ||
    currency.value.toLowerCase().contains(currencyInput.toLowerCase())){
      ulHTML += '''<li class='collection-item'>${currency.key} <span class='small'>${currency.value} </span></li>''';
    }
  }
  // update currency list inner html
  currencyList.innerHtml = ulHTML;
}

// clear user input
void clearUserInput(){
  (querySelector(_UISelectors["itemCurrencyInput"]) as InputElement).value = '';
  (querySelector(_UISelectors["itemAmountInput"]) as InputElement).value = '';
}

// set default state
void setDefaultState(){
  (querySelector(_UISelectors["itemCurrencyInput"]) as InputElement).disabled
  = false;
  clearUserInput();

  (querySelector(_UISelectors["addBtn"]) as HtmlElement).style.display =
  "inline";
  (querySelector(_UISelectors["updateBtn"]) as HtmlElement).style.display =
  "none";
  (querySelector(_UISelectors["backBtn"]) as HtmlElement).style.display =
  "none";
}

// set edit state
void setEditState(){
  (querySelector(_UISelectors["addBtn"]) as HtmlElement).style.display =
  "none";
  (querySelector(_UISelectors["updateBtn"]) as HtmlElement).style.display =
  "inline";
  (querySelector(_UISelectors["backBtn"]) as HtmlElement).style.display =
  "inline";
}

// check if items list empty
void toggleItemsListBorder(){
  final itemsList = querySelector(_UISelectors["itemsList"]) as UListElement;

  if(itemsList.children.isEmpty){
    itemsList.style.border = "none";
  } else {
    itemsList.style.border = "1px solid #e0e0e0";
  }
}

// show alert
void showAlert(String msg){

  HtmlElement alertDiv = querySelector(".card .alert") as HtmlElement;
  alertDiv.innerHtml = msg;
  alertDiv.style.display = "block";

  // set time out
  Timer(Duration(seconds: 3), hideAlert );
}

hideAlert(){
  (querySelector(".alert") as HtmlElement).style.display = "none";
}