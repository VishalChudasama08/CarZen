import 'package:flutter/material.dart';
import '../data/dummy_cars.dart';
import '../models/car.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_list.dart';
import '../widgets/car_card.dart';
import '../widgets/car_search_bar.dart';
import '../widgets/category_list.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hero_banner.dart';
import '../widgets/quick_filter_chips.dart';
import '../widgets/section_header.dart';

/// CarZen Home page.
///
/// This screen only *composes* widgets and holds local UI state (search
/// text, quick-filter selections, favorite toggles). Replace [dummyCars],
/// [popularBrands] and [carCategories] with real API calls once the
/// backend is ready — see [Car.fromJson] for the expected response shape.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  late List<Car> _cars = dummyCars;

  String _selectedBrand = quickFilterBrands.first;
  String _selectedPrice = quickFilterPrices.first;
  String _selectedFuel = quickFilterFuel.first;
  String _selectedTransmission = quickFilterTransmission.first;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFavorite(Car car, bool value) {
    setState(() {
      _cars = _cars.map((c) => c.id == car.id ? c.copyWith(isFavorite: value) : c).toList();
    });
  }

  void _handleSearch(String query) {
    // TODO: replace with a real API call, e.g.
    // final results = await ApiService.searchCars(query: query, brand: _selectedBrand, ...);
    debugPrint('Search submitted: "$query"');
  }

  void _handleExplore() {
    // TODO: navigate to the full car listing screen.
    debugPrint('Navigate to Explore Cars');
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      QuickFilter(
        label: 'Brand',
        icon: Icons.directions_car_outlined,
        value: _selectedBrand,
        options: quickFilterBrands,
        onChanged: (value) => setState(() => _selectedBrand = value),
      ),
      QuickFilter(
        label: 'Price',
        icon: Icons.sell_outlined,
        value: _selectedPrice,
        options: quickFilterPrices,
        onChanged: (value) => setState(() => _selectedPrice = value),
      ),
      QuickFilter(
        label: 'Fuel',
        icon: Icons.local_gas_station_outlined,
        value: _selectedFuel,
        options: quickFilterFuel,
        onChanged: (value) => setState(() => _selectedFuel = value),
      ),
      QuickFilter(
        label: 'Transmission',
        icon: Icons.settings_outlined,
        value: _selectedTransmission,
        options: quickFilterTransmission,
        onChanged: (value) => setState(() => _selectedTransmission = value),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            // TODO: re-fetch cars/brands/categories from the API.
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              CustomHomeAppBar(
                location: 'Ahmedabad, GJ',
                onLocationTap: () {},
                onNotificationTap: () {},
                onProfileTap: () {},
              ),
              HeroBanner(onExplorePressed: _handleExplore),
              CarSearchBar(
                controller: _searchController,
                onSubmitted: _handleSearch,
                onFilterTap: () {},
              ),
              const SizedBox(height: 14),
              QuickFilterChips(filters: filters),
              const SizedBox(height: 26),
              SectionHeader(title: 'Featured Cars', onActionTap: _handleExplore),
              SizedBox(
                height: 246,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _cars.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final car = _cars[index];
                    return CarCard(
                      car: car,
                      onTap: () {}, // TODO: navigate to car detail screen
                      onFavoriteToggle: (value) => _toggleFavorite(car, value),
                    );
                  },
                ),
              ),
              const SizedBox(height: 26),
              const SectionHeader(title: 'Popular Brands', actionLabel: null),
              BrandList(brands: popularBrands, onBrandTap: (brand) {}),
              const SizedBox(height: 26),
              const SectionHeader(title: 'Browse by Category', actionLabel: null),
              CategoryList(categories: carCategories, onCategoryTap: (category) {}),
            ],
          ),
        ),
      ),
    );
  }
}
