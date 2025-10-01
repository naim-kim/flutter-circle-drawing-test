# Flutter Circle Drawing Test

A Flutter application that tests and analyzes users' ability to draw accurate circles. This app provides real-time feedback and comprehensive performance analysis including accuracy scores, speed metrics, and smoothness evaluation.

## 📱 Features

- **Interactive Drawing Canvas** - Draw on a touch-responsive canvas with real-time coordinate tracking
- **Visual Guide** - Gray reference circle with center point to guide drawing
- **Real-time Feedback** - Live coordinate display and point counting
- **Comprehensive Analysis** - Detailed performance metrics and scoring
- **Visual Charts** - Accuracy heatmaps and speed analysis charts
- **Performance Scoring** - Overall score based on accuracy, speed, and smoothness

## 🖼️ Screenshots

### Drawing Interface

<p align="center">
  <img src="assets/folder-structure.png" alt="프로젝트 폴더 구조" width="500"/>
</p>

_Main drawing screen with reference circle and coordinate display_

### Analysis Dashboard

<!-- Add your screenshot here -->

_Comprehensive analysis with performance scores and metrics_

### Accuracy Analysis

<!-- Add your screenshot here -->

_Color-coded accuracy analysis showing deviations from perfect circle_

### Speed Chart

<!-- Add your screenshot here -->

_Drawing speed visualization over time_

## 🎯 How It Works

### Drawing Process

1. **Reference Circle**: A gray template circle is displayed in the center of the screen
2. **Drawing**: Users trace the circle using touch input
3. **Data Collection**: The app records every touch point with precise coordinates and timestamps
4. **Real-time Feedback**: Current position and total points are displayed during drawing

### Analysis & Scoring

#### 📊 Performance Metrics

**1. Accuracy Score (0-100)**

- Measures how closely the drawn path follows the ideal circle
- Calculated using deviation from the reference circle's radius
- Formula: `max(0, 100 - (avgDeviation × 1.5))`
- Lower deviations = higher scores

**2. Speed Score (0-100)**

- Evaluates consistency of drawing speed
- Based on speed variation throughout the drawing
- Formula: `max(0, 100 - (speedVariation ÷ 20))`
- More consistent speed = higher scores

**3. Smoothness Score (0-100)**

- Measures drawing fluidity and control
- Calculated from acceleration changes between points
- Formula: `max(0, 100 - (smoothnessVariation ÷ 200))`
- Smoother movements = higher scores

**4. Overall Score**

- Average of Accuracy, Speed, and Smoothness scores
- Provides comprehensive performance evaluation

#### 🧮 Detailed Calculations

**Deviation Calculation:**

```dart
double distanceToCenter = (drawingPoint - circleCenter).distance;
double deviation = abs(distanceToCenter - idealRadius);
```

**Speed Calculation:**

```dart
double distance = (currentPoint - previousPoint).distance;
int timeDiff = currentTime - previousTime; // milliseconds
double speed = distance / timeDiff * 1000; // pixels per second
```

**Smoothness Calculation:**

```dart
double acceleration = abs(currentSpeed - previousSpeed);
// Lower acceleration changes = smoother drawing
```

#### 📈 Rating System

- **90-100**: Excellent - Professional-level accuracy
- **80-89**: Very Good - High precision with minor deviations
- **70-79**: Good - Above average performance
- **60-69**: Average - Acceptable accuracy with room for improvement
- **Below 60**: Needs Practice - Significant deviations from target

## 🏗️ Technical Architecture

### Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── drawing_point.dart       # Data model for drawing points
├── screens/
│   ├── drawing_screen.dart      # Main drawing interface
│   └── analysis_screen.dart     # Results and analysis
├── widgets/
│   ├── drawing_canvas.dart      # Interactive drawing surface
│   ├── coordinate_display.dart  # Real-time position display
│   ├── score_card.dart         # Performance score widget
│   ├── anomaly_chart.dart      # Accuracy visualization
│   ├── speed_chart.dart        # Speed analysis chart
│   └── detailed_stats.dart     # Statistical information
├── painters/
│   ├── drawing_painter.dart         # Canvas rendering
│   ├── anomaly_chart_painter.dart   # Accuracy chart rendering
│   └── speed_chart_painter.dart     # Speed chart rendering
└── services/
    └── drawing_analyzer.dart    # Analysis algorithms
```

### Key Technologies

- **Flutter SDK**: Cross-platform mobile development
- **CustomPainter**: For rendering drawings and charts
- **GestureDetector**: Touch input handling
- **Canvas API**: Real-time drawing capabilities

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/flutter-circle-drawing-test.git
   cd flutter-circle-drawing-test
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Building for Release

**Android:**

```bash
flutter build apk --release
```

**iOS:**

```bash
flutter build ios --release
```

## 📊 Usage Instructions

### For Optimal Results:

1. **Start Position**: Begin at the 3 o'clock position of the reference circle
2. **Direction**: Draw clockwise for consistency
3. **Speed**: Maintain steady, moderate speed
4. **Accuracy**: Stay as close as possible to the gray reference line
5. **Completion**: Try to complete the full circle in one smooth motion

### Understanding Your Score:

- **Green areas** in accuracy chart = Good precision
- **Red areas** in accuracy chart = High deviation
- **Steady speed line** = Consistent drawing pace
- **Overall score >80** = Excellent performance

## 🔧 Configuration

### Adjusting Difficulty

You can modify the reference circle size in `drawing_screen.dart`:

```dart
double actualRadius = 100.0; // Change this value
```

### Scoring Sensitivity

Adjust scoring factors in `drawing_analyzer.dart`:

```dart
double accuracyScore = math.max(0, 100 - (avgDeviation * 1.5)); // Change multiplier
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Contributors and testers who helped improve the accuracy algorithms
- UI/UX inspiration from medical assessment applications

## 📧 Contact

For questions, suggestions, or support:

- Create an issue on GitHub
- Email: [your-email@example.com]

---

**Made with ❤️ using Flutter**
