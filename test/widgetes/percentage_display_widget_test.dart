import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organizamais/model/percentage_result.dart';
import 'package:organizamais/widgetes/percentage_display_widget.dart';
import 'package:organizamais/utils/color.dart';

void main() {
  group('PercentageDisplayWidget', () {
    // Helper function to create widget for testing
    Widget createWidget(PercentageResult result) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: PercentageDisplayWidget(result: result),
          ),
        ),
      );
    }

    group('Positive Percentage', () {
      testWidgets('should display positive percentage with green color and up arrow', (tester) async {
        final result = PercentageResult(
          percentage: 25.5,
          hasData: true,
          type: PercentageType.positive,
          displayText: '+25.5%',
        );

        await tester.pumpWidget(createWidget(result));

        // Check if the widget is displayed
        expect(find.byType(PercentageDisplayWidget), findsOneWidget);
        
        // Check if the text is correct
        expect(find.text('+25.5%'), findsOneWidget);
        
        // Check if the icon is correct
        expect(find.byIcon(Icons.trending_up), findsOneWidget);
        
        // Check container decoration
        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, DefaultColors.green.withValues(alpha: 0.1));
        expect(decoration.border?.top.color, DefaultColors.green.withValues(alpha: 0.3));
      });
    });

    group('Negative Percentage', () {
      testWidgets('should display negative percentage with red color and down arrow', (tester) async {
        final result = PercentageResult(
          percentage: -15.2,
          hasData: true,
          type: PercentageType.negative,
          displayText: '-15.2%',
        );

        await tester.pumpWidget(createWidget(result));

        // Check if the widget is displayed
        expect(find.byType(PercentageDisplayWidget), findsOneWidget);
        
        // Check if the text is correct
        expect(find.text('-15.2%'), findsOneWidget);
        
        // Check if the icon is correct
        expect(find.byIcon(Icons.trending_down), findsOneWidget);
        
        // Check text color
        final textWidget = tester.widget<Text>(find.text('-15.2%'));
        expect(textWidget.style?.color, DefaultColors.red);
        
        // Check icon color
        final iconWidget = tester.widget<Icon>(find.byIcon(Icons.trending_down));
        expect(iconWidget.color, DefaultColors.red);
      });
    });

    group('Neutral Percentage', () {
      testWidgets('should display neutral percentage with grey color and flat arrow', (tester) async {
        final result = PercentageResult(
          percentage: 0.0,
          hasData: true,
          type: PercentageType.neutral,
          displayText: '0.0%',
        );

        await tester.pumpWidget(createWidget(result));

        // Check if the widget is displayed
        expect(find.byType(PercentageDisplayWidget), findsOneWidget);
        
        // Check if the text is correct
        expect(find.text('0.0%'), findsOneWidget);
        
        // Check if the icon is correct
        expect(find.byIcon(Icons.trending_flat), findsOneWidget);
        
        // Check text color
        final textWidget = tester.widget<Text>(find.text('0.0%'));
        expect(textWidget.style?.color, DefaultColors.grey);
        
        // Check icon color
        final iconWidget = tester.widget<Icon>(find.byIcon(Icons.trending_flat));
        expect(iconWidget.color, DefaultColors.grey);
      });
    });

    group('New Data', () {
      testWidgets('should display "Novo" with grey color and new icon', (tester) async {
        final result = PercentageResult(
          percentage: 0.0,
          hasData: true,
          type: PercentageType.newData,
          displayText: 'Novo',
        );

        await tester.pumpWidget(createWidget(result));

        // Check if the widget is displayed
        expect(find.byType(PercentageDisplayWidget), findsOneWidget);
        
        // Check if the text is correct
        expect(find.text('Novo'), findsOneWidget);
        
        // Check if the icon is correct
        expect(find.byIcon(Icons.fiber_new), findsOneWidget);
        
        // Check text color
        final textWidget = tester.widget<Text>(find.text('Novo'));
        expect(textWidget.style?.color, DefaultColors.grey);
        
        // Check icon color
        final iconWidget = tester.widget<Icon>(find.byIcon(Icons.fiber_new));
        expect(iconWidget.color, DefaultColors.grey);
      });
    });

    group('No Data', () {
      testWidgets('should not display anything when hasData is false', (tester) async {
        final result = PercentageResult.noData();

        await tester.pumpWidget(createWidget(result));

        // Should find SizedBox.shrink() instead of the actual widget content
        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.text(''), findsNothing);
        expect(find.byType(Container), findsNothing);
      });
    });

    group('Widget Structure', () {
      testWidgets('should have correct widget structure', (tester) async {
        final result = PercentageResult(
          percentage: 10.0,
          hasData: true,
          type: PercentageType.positive,
          displayText: '+10.0%',
        );

        await tester.pumpWidget(createWidget(result));

        // Check widget hierarchy
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Row), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);
        expect(find.byType(SizedBox), findsWidgets); // Multiple SizedBoxes may exist
      });

      testWidgets('should have proper spacing between icon and text', (tester) async {
        final result = PercentageResult(
          percentage: 10.0,
          hasData: true,
          type: PercentageType.positive,
          displayText: '+10.0%',
        );

        await tester.pumpWidget(createWidget(result));

        // Find the SizedBox used for spacing - there may be multiple
        final sizedBoxes = find.byType(SizedBox);
        expect(sizedBoxes, findsWidgets);
        
        // Check that at least one SizedBox has width (for spacing)
        final sizedBoxWidgets = tester.widgetList<SizedBox>(sizedBoxes);
        final hasWidthSizedBox = sizedBoxWidgets.any((box) => box.width != null);
        expect(hasWidthSizedBox, true);
      });
    });

    group('Accessibility', () {
      testWidgets('should be accessible to screen readers', (tester) async {
        final result = PercentageResult(
          percentage: 25.0,
          hasData: true,
          type: PercentageType.positive,
          displayText: '+25.0%',
        );

        await tester.pumpWidget(createWidget(result));

        // Check if text is readable by screen readers
        expect(find.text('+25.0%'), findsOneWidget);
        
        // Verify the widget can be found by semantics
        await tester.pumpAndSettle();
        expect(tester.getSemantics(find.text('+25.0%')), isNotNull);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to different screen sizes', (tester) async {
        final result = PercentageResult(
          percentage: 15.0,
          hasData: true,
          type: PercentageType.positive,
          displayText: '+15.0%',
        );

        // Test with different screen sizes
        await tester.binding.setSurfaceSize(const Size(320, 568)); // Small screen
        await tester.pumpWidget(createWidget(result));
        expect(find.byType(PercentageDisplayWidget), findsOneWidget);

        await tester.binding.setSurfaceSize(const Size(414, 896)); // Large screen
        await tester.pumpWidget(createWidget(result));
        expect(find.byType(PercentageDisplayWidget), findsOneWidget);
        
        // Reset to default size
        await tester.binding.setSurfaceSize(const Size(800, 600));
      });
    });
  });
}