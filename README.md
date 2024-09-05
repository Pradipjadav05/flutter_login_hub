# flutter_login_hub

Flutter Login Hub is a customizable form-based UI widget designed for user login and registration processes. It provides a simple and flexible way to create login forms with a variety of input fields, form validation, and user interactions. The widget is highly configurable, supports different field types like text, email, password, and mobile numbers, and includes features like password visibility toggling, form validation, and a "Remember Me" option.


## Features

* Customizable input fields (e.g., text, mobile, email, password)
* Form validation with custom rules
* Password visibility toggling
* "Remember Me" checkbox
* Dynamic field creation based on configuration
* Optional logo/image display
* Works for both login and registration flows
* Easy customization for UI elements such as buttons and text styles


## Getting started

To use this package, add api_service_helper as a dependency in your pubspec.yaml file.

```dart
dependencies:
  flutter_login_hub: <latest_version>
```
Then, run the following command:

```dart
flutter pub get
```

## Usage

Super simple to use:
- Import the API service helper package.

```dart
    import 'package:flutter_login_hub/flutter_login_hub.dart';
```

## Examples

```dart
import 'package:flutter_login_hub/flutter_login_hub.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLoginHub(
        // Input field configuration
        inputFields: {
          "email": WidgetModel(
            fieldType: WidgetType.email,
            label: "Email",
            hintText: "Enter your email",
            // custom validator
            validator: (value) {
              if (value.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter value')),);
                return false;
              }
              return true;
            },
          ),
          "password": WidgetModel(
            fieldType: WidgetType.password,
            label: "Password",
            hintText: "Enter your password",
          ),
        },
        // Optional parameters
        image: ImageModel(imgPath: "assets/logo.png"),
        screenHeading: "Login",
        actionButtonName: "Sign In",
        addRememberMe: true,
        onProcess: (data, {isRemember}) {
          // Handle form submission
          
          if(isRemember != null && isRemember){
            // Proceed with further processing like pref, etc.
          }
          // Proceed with further processing like API calls, etc.
        },
      ),
    );
  }
}

```

-------------------
## Configuration Options
The Flutter Login Hub package provides several configuration options to customize the appearance and behavior of the form.

### Input Fields

You can customize the input fields by creating instances of the WidgetModel class. The following properties are available:

* `fieldType`: The type of the field (e.g., text, email, password, mobile)
* `hintText`: The placeholder text for the field
* `label`: The label text for the field
* `border`: The border style for the field
* `validator`: A custom validation function for the field
* `maxLength`: The maximum length of the field
* `isEnable`: Whether the field is enabled or disabled
* `readOnly`: Whether the field is read-only
* `hintStyle`: The style of the hint text
* `textStyle`: The style of the field text
* `obscuringCharacter`: The character used to obscure the field text (for password fields)
* `onChanged`: A callback function called when the field value changes
* `onFieldSubmitted`: A callback function called when the field is submitted
* `onTap`: A callback function called when the field is tapped
* `onEditingComplete`: A callback function called when the field editing is complete

### Image Fields

You can customize the image fields by creating instances of the ImageModel class. The following properties are available:

* `imgPath`: The path to the image
* `height`: The height of the image
* `width`: The width of the image

### Form Options

You can customize the form by passing the following options to the FlutterLoginHub constructor:

* `inputFields`: A map of input fields
* `image`: An optional image field
* `onProcess`: A callback function called when the form is submitted
* `actionButtonName`: The text of the submit button
* `screenHeading`: The heading text of the form
* `addRememberMe`: Whether to display the "Remember Me" checkbox
* `actionButtonStyle`: The style of the submit button
* `headingStyle`: The style of the heading text

------------------

<img src="https://github.com/user-attachments/assets/19ee35c8-c706-4161-85ca-a885414ff56f" alt="Screenshot_1725514306" height="300">

<img src="https://github.com/user-attachments/assets/1645aadb-1992-4acc-a3c2-83513428f655" alt="Screenshot_1725514363" height="300">

