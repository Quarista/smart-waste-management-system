import { saveConsoleMessageToFirestore, saveProtocolMonitorMessageToFirestore } from "./alertLogger";

const originalAlert = window.alert;

window.alert = function (message) {
  saveConsoleMessageToFirestore("alert", message);
  saveProtocolMonitorMessageToFirestore(message);
  originalAlert(message);
};

const originalConsole = {
  log: console.log,
  error: console.error,
  warn: console.warn,
  info: console.info,
  debug: console.debug,
};

console.log = function (...args) {
  const message = args.join(" ");
  saveConsoleMessageToFirestore("log", message);
  saveProtocolMonitorMessageToFirestore(message);
  originalConsole.log.apply(console, args);
};

console.error = function (...args) {
  const message = args.join(" ");
  saveConsoleMessageToFirestore("error", message);
  saveProtocolMonitorMessageToFirestore(message);
  originalConsole.error.apply(console, args);
};

console.warn = function (...args) {
  const message = args.join(" ");
  saveConsoleMessageToFirestore("warn", message);
  saveProtocolMonitorMessageToFirestore(message);
  originalConsole.warn.apply(console, args);
};

console.info = function (...args) {
  const message = args.join(" ");
  saveConsoleMessageToFirestore("info", message);
  saveProtocolMonitorMessageToFirestore(message);
  originalConsole.info.apply(console, args);
};

console.debug = function (...args) {
  const message = args.join(" ");
  saveConsoleMessageToFirestore("debug", message);
  saveProtocolMonitorMessageToFirestore(message);
  originalConsole.debug.apply(console, args);
};