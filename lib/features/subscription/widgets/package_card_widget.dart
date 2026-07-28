import '../../../../core/app_color.dart';
import '../../../../core/app_text_style.dart';
import 'package:flutter/material.dart';

class PackageCardWidget extends StatelessWidget {
  final int index;
  final String title;
  final String price;
  final IconData icon;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onSubscribeTap;
  final bool isPopular;
  final bool isActive;
  final int? remainingDays;

  const PackageCardWidget({
    super.key,
    required this.index,
    required this.title,
    required this.price,
    required this.icon,
    required this.features,
    required this.isSelected,
    required this.onTap,
    required this.onSubscribeTap,
    this.isPopular = false,
    this.isActive = false,
    this.remainingDays,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: _buildCardDecoration(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(children: [_buildHeader(), _buildFeatures()]),
            if (isPopular) _buildPopularBadge(),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: isSelected ? AppColors.primary1 : AppColors.border.withValues(alpha: 0.05), width: isSelected ? 2.5 : 1),
      boxShadow: [
        if (isSelected)
          BoxShadow(color: AppColors.primary1.withValues(alpha: 0.15), blurRadius: 24, spreadRadius: 4, offset: const Offset(0, 10))
        else
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, spreadRadius: 0, offset: const Offset(0, 5)),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary1.withValues(alpha: 0.03) : Colors.transparent,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeaderIcon(),
          const SizedBox(width: 16),
          Expanded(child: _buildHeaderTitle()),
          _buildSelectionIndicator(),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected ? [AppColors.linearGradient1, AppColors.linearGradient2] : [Colors.grey.shade100, Colors.grey.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected ? [BoxShadow(color: AppColors.primary1.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))] : null,
      ),
      child: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600, size: 28),
    );
  }

  Widget _buildHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.font16w600BlackSF.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? AppColors.primary1 : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(price, style: AppTextStyles.font20w700BlackSF.copyWith(color: AppColors.textPrimary, letterSpacing: -0.5)),
        if (isActive) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary5.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.primary5, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Đang dùng${remainingDays != null ? ' ($remainingDays ngày)' : ''}',
                  style: AppTextStyles.font12w600BlackSF.copyWith(color: AppColors.primary5),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectionIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary1 : Colors.white,
        border: Border.all(color: isSelected ? AppColors.primary1 : Colors.grey.shade300, width: 2),
        boxShadow: isSelected ? [BoxShadow(color: AppColors.primary1.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
      ),
      child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
    );
  }

  Widget _buildFeatures() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 16),
          ...features.map((feature) => _buildFeatureItem(feature)),
          if (isSelected) ...[const SizedBox(height: 24), _buildSubscribeButton()],
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? AppColors.primary1.withValues(alpha: 0.1) : Colors.grey.shade100),
            child: Icon(Icons.check_rounded, color: isSelected ? AppColors.primary1 : Colors.grey.shade400, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(feature, style: AppTextStyles.font14w400BlackSF.copyWith(color: isSelected ? Colors.black87 : Colors.black54, height: 1.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.grey.shade200 : null,
          gradient: isActive
              ? null
              : const LinearGradient(
                  colors: [AppColors.linearGradient1, AppColors.linearGradient2],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive ? [] : [BoxShadow(color: AppColors.primary1.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6))],
        ),
        child: ElevatedButton(
          onPressed: isActive ? null : onSubscribeTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            isActive ? 'Gói đang sử dụng' : 'Đăng ký ngay',
            style: AppTextStyles.font16w600WhiteSF.copyWith(
              fontSize: 16,
              letterSpacing: 0.5,
              color: isActive ? Colors.grey.shade500 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularBadge() {
    return Positioned(
      top: -14,
      right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFF8C00), Color(0xFFFF5252)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFFFF5252).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text('Phổ biến nhất', style: AppTextStyles.font12w600BlackSF.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
