import 'package:laravel_exception/src/exceptions/imp.dart';

class LValidationException extends LaravelException {
  final Map<String, List> _errors;

  LValidationException(
    Map<String, dynamic> response,
  )   : _errors = Map<String, List>.from(
          response['errors'] ?? response['error'] ?? {},
        ),
        super(response: response);

  /// contains the failed input keys in the exception object
  List<String> get keys => _errors.keys.toList();

  List<String> errors() {
    List<List<String>> errorsList = _errors.values.cast<List<String>>().toList();
    errorsList.removeWhere((element) => element.isEmpty);
    List<String> errors = [];
    for (List<String> element in errorsList) {
      if (element.length == 1) {
        errors.add(element.first);
        continue;
      }

      errors.add(element.join("\n"));
    }
    return errors;
  }

  String get firstErrorKey => keys.first;

  List<String> get firstErrorMessages => errorsByKey(firstErrorKey)!;

  List<String>? errorsByKey(String key) => _errors[key]?.cast<String>();

  String? errorsCombinedByKey(String key) => _errors[key]?.cast<String>().join("\n");

  String get errorsCombined => errors().join("\n");

  @override
  List<Object?> get props => [
        message,
        response,
        _errors,
      ];

  @override
  String toString() {
    /// String buffer that will contains the error messages in string
    final buffer = StringBuffer();

    /// to extract failure message and build String object
    /// that will contain the full failure message
    ///
    for (int felidIndex = 0; felidIndex < keys.length; felidIndex++) {
      final currentFelid = keys[felidIndex];
      final errorBuffer = StringBuffer();
      errorBuffer.write(currentFelid);

      /// extract currentFelid messages
      for (int i = 0; i < _errors[currentFelid]!.length; i++) {
        final currentMessage = _errors[currentFelid];

        /// whether  is last msg in this key or not
        final isLastMsg = i == _errors.keys.length;

        /// append the message
        errorBuffer.write('$currentFelid $currentMessage${isLastMsg ? '\n' : ''}');
      }

      /// append the message
      buffer.write('$errorBuffer\n');
    }

    /// covert the buffer to string
    return buffer.toString();
  }
}
