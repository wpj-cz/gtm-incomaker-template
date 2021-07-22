___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "WPJ Incomaker",
  "categories": ["EMAIL_MARKETING"],
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "GROUP",
    "name": "Povolené eventy",
    "displayName": "Povolené eventy",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "event_purchase",
        "checkboxText": "purchase",
        "simpleValueType": true
      },
      {
        "type": "CHECKBOX",
        "name": "event_search",
        "checkboxText": "search",
        "simpleValueType": true
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "dp",
    "displayName": "page",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "tid",
    "displayName": "Tracking ID",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "ec",
    "displayName": "Event Category",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "ds",
    "displayName": "Data source",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "ea",
    "displayName": "Event Action",
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_SERVER___

const getAllEventData = require('getAllEventData');
const sendHttpRequest = require('sendHttpRequest');
const encodeUriComponent = require('encodeUriComponent');
const makeInteger = require('makeInteger');
const makeString = require('makeString');
const JSON = require('JSON');
const logToConsole = require('logToConsole');

const eventData = getAllEventData();
logToConsole(data);

const eventName = 'event_' + (eventData.event_name || 'fallback');

// check if event is enabled
if(data[eventName] === 'undefined' || !data[eventName]) {
  data.gtmOnFailure();
  return;
}

// events mappings
const UA_PURCHASE_MAPPING = {
    "event_name": "pa",
	"transaction_id": "ti",
	"currency": "cu",
	"value": "tr",
    "user_id": "uid",
    "client_id": "cid",
};

const UA_ITEM_MAPPING = {
	"item_id": "pr{i}id",
	"item_name": "pr{i}nm",
	"item_brand": "pr{i}br",
	"quantity": "pr{i}qt",
	"price": "pr{i}pr",
    "fullCategories": "pr{i}ca",
    "margin":"pr{i}cm1",
};


function concatCategories(items) {
  let parts = [];
  for(let i = 1; i <=5; i++) {
    const part = items['item_category'+i] || false;
    if(part) {
      parts.push(items['item_category'+i]);
    }
  }
  
  return parts.join('/');
}

let eventFunctions = [];

// purchase convertion function
eventFunctions.event_purchase = function (dataGA4) {
    function purchaseGetKey(key) {
	  return UA_PURCHASE_MAPPING[key] || '';
    }

    function itemGetKey(key, index) {
	  return (UA_ITEM_MAPPING[key] || '').replace('{i}', index);
    }
  
	let params = {};
  
	for (let key in dataGA4) {
		if (key !== 'items') {
			const newKey = purchaseGetKey(key);
			if (newKey) {
				params[newKey] = dataGA4[key] || '';
			}
		}
	}

	for (let itemIndex in dataGA4.items || []) {
      //spojeni kategorii
      dataGA4.items[itemIndex].fullCategories = concatCategories(dataGA4.items[itemIndex]);
      dataGA4.items[itemIndex].margin = (dataGA4.items[itemIndex].price - dataGA4.items[itemIndex].price_buy) *           dataGA4.items[itemIndex].quantity;
      
      // převedení na z GA4 na UA podle UA_ITEM_MAPPING
		for (let key in dataGA4.items[itemIndex]) {
			const newKey = itemGetKey(key, makeInteger(itemIndex) + 1);
			if (newKey) {
				params[newKey] = dataGA4.items[itemIndex][key] || '';
			}
		}

	}
  
  return params;
};


let params = eventFunctions[eventName](eventData);


//https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters

params.tid = data.tid; //tracking id (required)
params.ec = data.ec || '';
params.ds = data.ds || ''; 
params.ea = data.ea || '';
//params.dp = data.dp || eventData.path || ''; //path (required)
params.t = 'event'; //hit type (required)
params.v = '1'; //app version (required)
params.ni = '1';

let queryString = '';
for (const key in params) {
	queryString += key + '=' + encodeUriComponent(makeString(params[key])) + '&';
}
queryString = queryString.slice(0, -1);

const url = 'https://www.google-analytics.com/collect';

logToConsole(queryString);

const requestHeaders = {
	headers: {
		'content-type': 'application/x-www-form-urlencoded'
	},
	method: 'POST'
};
sendHttpRequest(
	url,
	(statusCode, headers, response) => {
		if (statusCode >= 200 && statusCode < 300) {
			data.gtmOnSuccess();
			return;
		}
		data.gtmOnFailure();
	},
	requestHeaders, queryString);


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "all"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 7/22/2021, 11:55:49 AM


