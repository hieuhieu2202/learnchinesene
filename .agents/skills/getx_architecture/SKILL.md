---
name: GetX Architecture and State Management
description: Rules for creating screens, controllers, and managing state using GetX in this project.
---

# Architecture & State Management Guidelines

This project uses **GetX** for State Management, Dependency Injection, and Navigation. When creating new features, screens, or components, strictly follow these structural and architectural patterns.

## Directory Structure

Features are organized into distinct folders under `lib/screen/screen/`. For a given feature (e.g., `feature_name`), the structure should be:

```text
lib/screen/screen/feature_name/
├── controller/
│   └── feature_name_controller.dart   # The GetX controller for the feature
├── view/
│   └── custom_widget.dart             # Local/helper widgets specific to this screen
└── feature_name_screen.dart       # The main StatefulWidget for the screen
```

## State Management (GetX Controllers)

1. **Creating Controllers:**
   - Place controllers in the `controller` directory of the feature.
   - Extend `GetxController`.
   - Use `Rx` variables (`RxBool`, `RxString`, `RxList`, etc.) for reactive state.
   - Use `.value` to access or update the reactive variables.

   ```dart
   import 'package:get/get.dart';

   class FeatureNameController extends GetxController {
     final isLoading = false.obs;
     final items = <String>[].obs;

     void fetchData() {
       isLoading.value = true;
       // ... fetch data
       isLoading.value = false;
     }
   }
   ```

2. **UI Binding:**
   - Use `Obx(() => ...)` inside your widget's `build` method to rebuild specific parts of the UI when a reactive variable changes.
   - Do **NOT** use `GetBuilder` unless specifically required; prefer `Obx` for fine-grained reactivity.

## Dependency Injection

1. **Global Controllers:**
   If a controller needs to be available globally from app startup (e.g., `HomeController`, `LanguageController`), register it in `lib/di.dart`:
   ```dart
   final featureNameController = FeatureNameController();
   Get.lazyPut(() => featureNameController, fenix: true);
   ```
   Access it in the screen via `Get.find()`:
   ```dart
   class _FeatureNameScreenState extends State<FeatureNameScreen> {
     final ctl = Get.find<FeatureNameController>();
     // ...
   }
   ```

2. **Screen-Specific Controllers:**
   If a controller is only needed for a specific screen (e.g., `RouletteListController`), initialize it directly in the `State` of your `StatefulWidget` using `Get.put()`:
   ```dart
   class _FeatureNameScreenState extends State<FeatureNameScreen> {
     final controller = Get.put(FeatureNameController());

     @override
     void dispose() {
       // Optional: explicit clean up if necessary
       super.dispose();
     }
   }
   ```

## Navigation

- Always use GetX for navigation.
- Use `Get.to(() => const TargetScreen())` or `Get.to(const TargetScreen())` to navigate.
- Use `Get.back()` to pop the current screen.
