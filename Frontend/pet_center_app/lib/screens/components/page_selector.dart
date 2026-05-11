import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PageSelector extends StatefulWidget {
  final int maxPage;
  final ValueChanged<int> onChanged;

  const PageSelector({
    super.key,
    required this.maxPage,
    required this.onChanged,
  });

  @override
  State<PageSelector> createState() => _PageSelectorState();
}

class _PageSelectorState extends State<PageSelector> {
  late TextEditingController controller;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: currentPage.toString());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void changePage(int page) {
    if (page < 1 || page > widget.maxPage) return;

    setState(() {
      currentPage = page;
      controller.text = currentPage.toString();
    });

    widget.onChanged(page - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: currentPage > 1 ? () => changePage(currentPage - 1) : null,
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
          onPressed: currentPage < widget.maxPage
              ? () => changePage(currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
