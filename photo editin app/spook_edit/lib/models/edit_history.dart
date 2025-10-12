import 'dart:typed_data';

/// Represents a single edit state in the editing history
class EditState {
  final Uint8List imageData;
  final DateTime timestamp;
  final String? description;

  EditState({
    required this.imageData,
    required this.timestamp,
    this.description,
  });

  EditState copyWith({
    Uint8List? imageData,
    DateTime? timestamp,
    String? description,
  }) {
    return EditState(
      imageData: imageData ?? this.imageData,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
    );
  }
}

/// Manages undo/redo history for image editing
class EditHistory {
  final List<EditState> _history = [];
  int _currentIndex = -1;
  final int maxHistorySize;

  EditHistory({this.maxHistorySize = 20});

  /// Add a new edit state to history
  void addState(Uint8List imageData, {String? description}) {
    // Remove any states after current index (when undoing then making new edit)
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    // Add new state
    _history.add(EditState(
      imageData: imageData,
      timestamp: DateTime.now(),
      description: description,
    ));

    // Maintain max size
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
    } else {
      _currentIndex++;
    }
  }

  /// Undo to previous state
  EditState? undo() {
    if (canUndo) {
      _currentIndex--;
      return _history[_currentIndex];
    }
    return null;
  }

  /// Redo to next state
  EditState? redo() {
    if (canRedo) {
      _currentIndex++;
      return _history[_currentIndex];
    }
    return null;
  }

  /// Get current edit state
  EditState? get currentState {
    if (_currentIndex >= 0 && _currentIndex < _history.length) {
      return _history[_currentIndex];
    }
    return null;
  }

  /// Check if undo is available
  bool get canUndo => _currentIndex > 0;

  /// Check if redo is available
  bool get canRedo => _currentIndex < _history.length - 1;

  /// Clear all history
  void clear() {
    _history.clear();
    _currentIndex = -1;
  }

  /// Get history size
  int get size => _history.length;

  /// Get current index in history
  int get currentIndex => _currentIndex;
}
