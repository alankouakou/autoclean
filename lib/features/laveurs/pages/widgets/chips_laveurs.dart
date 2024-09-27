import 'package:autoclean/features/laveurs/services/laveur_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/laveur.dart';

class LaveurChips extends ConsumerStatefulWidget {
  final List<Laveur> laveurs;
  const LaveurChips({super.key, required this.laveurs});

  @override
  ConsumerState<LaveurChips> createState() => _LaveurChipState();
}

class _LaveurChipState extends ConsumerState<LaveurChips> {
  int _choiceIndex = -1;
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.white,
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.laveurs.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: ChoiceChip(
                label: Text(widget.laveurs[index].nom),
                side: BorderSide.none,
                selected: _choiceIndex == index ? true : false,
                shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.circular(20.0)),
                backgroundColor: Colors.grey.shade100,
                selectedColor: Colors.lightBlue,
                onSelected: (value) {
                  setState(() {
                    _choiceIndex = index;
                    ref.read(selectedLaveur.notifier).state =
                        widget.laveurs[index].id;
                    print('Nlle valeur laveur: ${widget.laveurs[index].id}');
                  });
                }),
          ),
        ),
      ),
    );
  }
}
