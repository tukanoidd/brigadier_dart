import 'dynamic_2_command_exception_type.dart';
import 'dynamic_command_exception_type.dart';
import 'simple_command_exception_type.dart';

abstract class BuiltInExceptionProvider {
    Dynamic2CommandExceptionType get doubleTooLow;

    Dynamic2CommandExceptionType get doubleTooHigh;

    Dynamic2CommandExceptionType get integerTooLow;

    Dynamic2CommandExceptionType get integerTooHigh;

    DynamicCommandExceptionType get literalIncorrect;

    SimpleCommandExceptionType get readerExpectedStartOfQuote;

    SimpleCommandExceptionType get readerExpectedEndOfQuote;

    DynamicCommandExceptionType get readerInvalidEscape;

    DynamicCommandExceptionType get readerInvalidBool;

    DynamicCommandExceptionType get readerInvalidInt;

    SimpleCommandExceptionType get readerExpectedInt;

    DynamicCommandExceptionType get readerInvalidDouble;

    SimpleCommandExceptionType get readerExpectedDouble;

    SimpleCommandExceptionType get readerExpectedBool;

    DynamicCommandExceptionType get readerExpectedSymbol;

    SimpleCommandExceptionType get dispatcherUnknownCommand;

    SimpleCommandExceptionType get dispatcherUnknownArgument;

    SimpleCommandExceptionType get dispatcherExpectedArgumentSeparator;

    DynamicCommandExceptionType get dispatcherParseException;
}
