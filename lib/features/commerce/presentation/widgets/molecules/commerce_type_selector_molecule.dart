import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/business_selection/models/business_type.dart';
import 'package:pickmeup_dashboard/features/business_selection/presentation/widgets/business_type_card.dart';

class CommerceTypeSelectorMolecule extends StatelessWidget {
  final BusinessType? selectedType;
  final ValueChanged<BusinessType> onSelectType;
  final bool isCompact;

  const CommerceTypeSelectorMolecule({
    super.key,
    required this.selectedType,
    required this.onSelectType,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final types = BusinessType.availableTypes;
    final isWeb = MediaQuery.of(context).size.width >= 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de negocio',
          style: PuTextStyle.title3.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Selecciona el tipo que mejor describa tu comercio',
          style: PuTextStyle.description1.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        if (isWeb)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.85,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: types.length,
            itemBuilder: (context, index) {
              final type = types[index];
              return BusinessTypeCard(
                businessType: type,
                isSelected: selectedType?.id == type.id,
                onTap: () => onSelectType(type),
                isCompact: true,
              );
            },
          )
        else if (isCompact)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: types.length,
            itemBuilder: (context, index) {
              final type = types[index];
              return BusinessTypeCard(
                businessType: type,
                isSelected: selectedType?.id == type.id,
                onTap: () => onSelectType(type),
                isCompact: true,
              );
            },
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: types.length,
            itemBuilder: (context, index) {
              final type = types[index];
              return BusinessTypeCardMobile(
                businessType: type,
                isSelected: selectedType?.id == type.id,
                onTap: () => onSelectType(type),
              );
            },
          ),
      ],
    );
  }
}
