import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/address_model.dart';
import '../../providers/app_state_provider.dart';

class AddressesManagementScreen extends StatelessWidget {
  const AddressesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Delivery Addresses',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: state.addresses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final addr = state.addresses[idx];
            final isSelected = addr.addressId == state.selectedAddressId;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.borderColor,
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  state.setSelectedAddress(addr.addressId);
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.textMuted,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                addr.label,
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.tileBlueBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'DEFAULT',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.primaryBlue,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            addr.fullAddress,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle,
                          color: AppColors.primaryBlue, size: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Address',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: () => _showAddAddressDialog(context, state),
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context, AppStateProvider state) {
    final labelCtrl = TextEditingController(text: 'Home 2');
    final plotCtrl = TextEditingController(text: 'Plot 7741');
    final streetCtrl = TextEditingController(text: 'Machel Way');
    String selectedDistrict = state.districts.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Delivery Address',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: labelCtrl,
                    decoration: const InputDecoration(labelText: 'Label (e.g. Home, Work)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: plotCtrl,
                    decoration: const InputDecoration(labelText: 'Plot / Unit Number'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: streetCtrl,
                    decoration: const InputDecoration(labelText: 'Street Name'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedDistrict,
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(labelText: 'District'),
                    items: state.districts
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedDistrict = val);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final newAddr = AddressModel(
                          addressId: 'addr-${DateTime.now().millisecondsSinceEpoch}',
                          userId: state.currentUser?.userId ?? 'guest',
                          label: labelCtrl.text.trim(),
                          plotUnit: plotCtrl.text.trim(),
                          street: streetCtrl.text.trim(),
                          city: 'Gaborone',
                          district: selectedDistrict,
                          latitude: -24.6400,
                          longitude: 25.9100,
                        );
                        state.addAddress(newAddr);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save Address'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
