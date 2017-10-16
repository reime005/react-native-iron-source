'use strict';

import {
  NativeModules,
  DeviceEventEmitter,
} from 'react-native';

const RNIronSourceOfferwall = NativeModules.RNIronSourceOfferwall;

const eventHandlers = {
  offerwallHasChangedAvailability: new Map(),
  offerwallDidShow: new Map(),
  offerwallDidFailToShowWithError: new Map(),
  offerwallDidClose: new Map(),
  didReceiveOfferwallCredits: new Map(),
  didFailToReceiveOfferwallCreditsWithError: new Map(),
};

const addEventListener = (type, handler) => {
  switch (type) {
    case 'offerwallHasChangedAvailability':
    case 'offerwallDidShow':
    case 'offerwallDidFailToShowWithError':
    case 'offerwallDidClose':
    case 'didReceiveOfferwallCredits':
    case 'didFailToReceiveOfferwallCreditsWithError':
      eventHandlers[type].set(handler, DeviceEventEmitter.addListener(type, handler));
      break;
    default:
      console.log(`Event with type ${type} does not exist.`);
  }
}

const removeEventListener = (type, handler) => {
  if (!eventHandlers[type].has(handler)) {
    return;
  }
  eventHandlers[type].get(handler).remove();
  eventHandlers[type].delete(handler);
}

const removeAllListeners = () => {
  DeviceEventEmitter.removeAllListeners('offerwallHasChangedAvailability');
  DeviceEventEmitter.removeAllListeners('offerwallDidShow');
  DeviceEventEmitter.removeAllListeners('offerwallDidFailToShowWithError');
  DeviceEventEmitter.removeAllListeners('offerwallDidClose');
  DeviceEventEmitter.removeAllListeners('didReceiveOfferwallCredits');
  DeviceEventEmitter.removeAllListeners('didFailToReceiveOfferwallCreditsWithError');
};

module.exports = {
  ...RNIronSourceOfferwall,
  initializeOfferwall: (key, userId, debug) => RNIronSourceOfferwall.initializeOfferwall(key, userId, debug),
  showOfferwall: (placementName) => RNIronSourceOfferwall.showOfferwall(placementName),
  getCredits: () => RNIronSourceOfferwall.getCredits(),
  addEventListener,
  removeEventListener,
  removeAllListeners
};
