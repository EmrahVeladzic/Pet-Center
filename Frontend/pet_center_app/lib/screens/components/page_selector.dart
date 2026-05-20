import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';

class PageSelector extends StatefulWidget {
  final int maxPage;
  final ValueChanged<int> onChanged;

  const PageSelector({
    super.key,
    required this.maxPage,
    required this.onChanged,
  });

  @override
  State<PageSelector> createState() => PageSelectorState();
}

class PageSelectorState extends State<PageSelector> {
  late TextEditingController controller;
  late int maxPage;
  int currentPage = 1;
  int _lastConfirmedPage = 1;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: currentPage.toString());
    maxPage = widget.maxPage;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void resetMax(int newMax) {
    if (!mounted) {
      return;
    }
    setState(() {
      maxPage = newMax;
      currentPage = 1;
      _lastConfirmedPage = 1;
    });
    changePage(1);
  }

  void revertPage() {
    setState(() {
      currentPage = _lastConfirmedPage;
      controller.text = currentPage.toString();
    });
  }

  void changePage(int page) {
    if (apiServiceBusy.value) {
      controller.text = currentPage.toString();
      return;
    }
    if (page < 1 || page > maxPage) {
      controller.text = currentPage.toString();
      return;
    }

    _lastConfirmedPage = currentPage;
    setState(() {
      currentPage = page;
      controller.text = currentPage.toString();
    });

    widget.onChanged(page - 1);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: panelTone,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: currentPage > 1
                ? () => changePage(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),

          SizedBox(
            width: 60,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (value) {
                final page = int.tryParse(value);

                if (page != null) {
                  changePage(page);
                } else {
                  controller.text = currentPage.toString();
                }
              },
            ),
          ),

          IconButton(
            onPressed: currentPage < maxPage
                ? () => changePage(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
