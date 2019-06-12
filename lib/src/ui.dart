import 'dart:html';
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

  // TODO: updateTotalMoney();
  // check if items list previously empty
  checkForListItems();
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
  // TODO: update total money
  // updateTotalMoney();
}

void deleteListItemUI(String id){
  (querySelector('[data-id="$id"]') as HtmlElement).remove();
  // TODO: update total money
  // updateTotalMoney();
  // check if any list item left
  checkForListItems();
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
void checkForListItems(){
  final itemsList = querySelector(_UISelectors["itemsList"]) as UListElement;

  if(itemsList.children.isEmpty){
    itemsList.style.border = "none";
  } else {
    itemsList.style.border = "1px solid #e0e0e0";
  }
}