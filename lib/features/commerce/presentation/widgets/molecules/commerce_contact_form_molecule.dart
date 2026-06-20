import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

class CommerceContactFormMolecule extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final bool isCompact;

  const CommerceContactFormMolecule({
    super.key,
    required this.phoneController,
    required this.addressController,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información de contacto',
          style: PuTextStyle.title3.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Datos opcionales para que te encuentren',
          style: PuTextStyle.description1.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        if (isCompact)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PUInput(
                  controller: phoneController,
                  hintText: 'Ej: +54 11 1234-5678',
                  labelText: 'Teléfono',
                  textInputType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PUInput(
                  controller: addressController,
                  hintText: 'Ej: Av. Siempre Viva 123',
                  labelText: 'Dirección',
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              PUInput(
                controller: phoneController,
                hintText: 'Ej: +54 11 1234-5678',
                labelText: 'Teléfono',
                textInputType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              PUInput(
                controller: addressController,
                hintText: 'Ej: Av. Siempre Viva 123',
                labelText: 'Dirección',
                textInputType: TextInputType.text,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
      ],
    );
  }
}
