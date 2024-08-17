import "package:autoclean/providers/tarifs_provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class TarifChips extends ConsumerStatefulWidget {
  final List tarifs;
  const TarifChips({super.key, required this.tarifs});

  @override
  ConsumerState<TarifChips> createState() => _MyChoiceChipState();
}

class _MyChoiceChipState extends ConsumerState<TarifChips> {
  int _choiceIndex = -1;
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SizedBox(
        height: 70,
        width: double.infinity,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.tarifs.length,
          itemBuilder: (context, index) => ChoiceChip(
              label: Text(widget.tarifs[index]),
              side: BorderSide.none,
              selected: _choiceIndex == index ? true : false,
              shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.circular(20.0)),
              backgroundColor: Colors.grey.shade100,
              selectedColor: Colors.yellow,
              onSelected: (value) {
                setState(() {
                  _choiceIndex = index;
                  ref.read(selectedTarifName.notifier).state =
                      widget.tarifs[index];
                });
              }),
        ),
      ),
    );
  }
}
