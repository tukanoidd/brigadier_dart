import 'package:brigadier_dart/src/literal_message.dart';

import 'built_in_exception_provider.dart';
import 'dynamic_2_command_exception_type.dart';
import 'dynamic_command_exception_type.dart';
import 'simple_command_exception_type.dart';

class BuiltInExceptions implements BuiltInExceptionProvider {
  // Double
  static final Dynamic2CommandExceptionType _DOUBLE_TOO_SMALL =
      Dynamic2CommandExceptionType((found, min) => LiteralMessage(
          'Double must not be less than ' + min + ', found ' + found));

  static final Dynamic2CommandExceptionType _DOUBLE_TOO_BIG =
      Dynamic2CommandExceptionType((found, max) => LiteralMessage(
          'Double must not be more than ' + max + ', found ' + found));

  // Int
  static final Dynamic2CommandExceptionType _INTEGER_TOO_SMALL =
      Dynamic2CommandExceptionType((found, min) => LiteralMessage(
          'Integer must not be less than ' + min + ', found ' + found));

  static final Dynamic2CommandExceptionType _INTEGER_TOO_BIG =
      Dynamic2CommandExceptionType((found, max) => LiteralMessage(
          'Integer must not be more than ' + max + ', found ' + found));

  // Literal
  static final DynamicCommandExceptionType _LITERAL_INCORRECT =
      DynamicCommandExceptionType(
          (expected) => LiteralMessage('Expected literal ' + expected));

  // Reader
  static final SimpleCommandExceptionType _READER_EXPECTED_START_OF_QUOTE =
      SimpleCommandExceptionType(
          LiteralMessage('Expected quote to start a string'));

  static final SimpleCommandExceptionType _READER_EXPECTED_END_OF_QUOTE =
      SimpleCommandExceptionType(LiteralMessage('Unclosed quoted string'));

  static final DynamicCommandExceptionType _READER_INVALID_ESCAPE =
      DynamicCommandExceptionType((character) => LiteralMessage(
          "Invalid escape sequence '" + character + "' in quoted string"));

  static final DynamicCommandExceptionType _READER_INVALID_BOOL =
      DynamicCommandExceptionType((value) => LiteralMessage(
          "Invalid bool, expected true or false but found '" + value + "'"));

  static final DynamicCommandExceptionType _READER_INVALID_INT =
      DynamicCommandExceptionType(
          (value) => LiteralMessage("Invalid integer '" + value + "'"));

  static final SimpleCommandExceptionType _READER_EXPECTED_INT =
      SimpleCommandExceptionType(LiteralMessage('Expected integer'));

  static final DynamicCommandExceptionType _READER_INVALID_DOUBLE =
      DynamicCommandExceptionType(
          (value) => LiteralMessage("Invalid double '" + value + "'"));

  static final SimpleCommandExceptionType _READER_EXPECTED_DOUBLE =
      SimpleCommandExceptionType(LiteralMessage('Expected double'));

  static final SimpleCommandExceptionType _READER_EXPECTED_BOOL =
      SimpleCommandExceptionType(LiteralMessage('Expected bool'));

  static final DynamicCommandExceptionType _READER_EXPECTED_SYMBOL =
      DynamicCommandExceptionType(
          (symbol) => LiteralMessage("Expected '" + symbol + "'"));

  // Dispatcher
  static final SimpleCommandExceptionType _DISPATCHER_UNKNOWN_COMMAND =
      SimpleCommandExceptionType(LiteralMessage('Unknown command'));

  static final SimpleCommandExceptionType _DISPATCHER_UNKNOWN_ARGUMENT =
      SimpleCommandExceptionType(
          LiteralMessage('Incorrect argument for command'));

  static final SimpleCommandExceptionType
      _DISPATCHER_EXPECTED_ARGUMENT_SEPARATOR =
      SimpleCommandExceptionType(LiteralMessage(
          'Expected whitespace to end one argument, but found trailing data'));

  static final DynamicCommandExceptionType _DISPATCHER_PARSE_EXCEPTION =
      DynamicCommandExceptionType(
          (message) => LiteralMessage('Could not parse command: ' + message));

  @override
  Dynamic2CommandExceptionType get doubleTooLow => _DOUBLE_TOO_SMALL;

  @override
  Dynamic2CommandExceptionType get doubleTooHigh => _DOUBLE_TOO_BIG;

  @override
  Dynamic2CommandExceptionType get integerTooLow => _INTEGER_TOO_SMALL;

  @override
  Dynamic2CommandExceptionType get integerTooHigh => _INTEGER_TOO_BIG;

  @override
  DynamicCommandExceptionType get literalIncorrect => _LITERAL_INCORRECT;

  @override
  SimpleCommandExceptionType get readerExpectedStartOfQuote =>
      _READER_EXPECTED_START_OF_QUOTE;

  @override
  SimpleCommandExceptionType get readerExpectedEndOfQuote =>
      _READER_EXPECTED_END_OF_QUOTE;

  @override
  DynamicCommandExceptionType get readerInvalidEscape => _READER_INVALID_ESCAPE;

  @override
  DynamicCommandExceptionType get readerInvalidBool => _READER_INVALID_BOOL;

  @override
  DynamicCommandExceptionType get readerInvalidInt => _READER_INVALID_INT;

  @override
  SimpleCommandExceptionType get readerExpectedInt => _READER_EXPECTED_INT;

  @override
  DynamicCommandExceptionType get readerInvalidDouble => _READER_INVALID_DOUBLE;

  @override
  SimpleCommandExceptionType get readerExpectedDouble => _READER_EXPECTED_DOUBLE;

  @override
  SimpleCommandExceptionType get readerExpectedBool => _READER_EXPECTED_BOOL;

  @override
  DynamicCommandExceptionType get readerExpectedSymbol => _READER_EXPECTED_SYMBOL;

  @override
  SimpleCommandExceptionType get dispatcherUnknownCommand =>
      _DISPATCHER_UNKNOWN_COMMAND;

  @override
  SimpleCommandExceptionType get dispatcherUnknownArgument =>
      _DISPATCHER_UNKNOWN_ARGUMENT;

  @override
  SimpleCommandExceptionType get dispatcherExpectedArgumentSeparator =>
      _DISPATCHER_EXPECTED_ARGUMENT_SEPARATOR;

  @override
  DynamicCommandExceptionType get dispatcherParseException =>
      _DISPATCHER_PARSE_EXCEPTION;
}
