import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:semana4/theme.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:semana4/models/product.dart';
import 'package:semana4/services/product_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ejemplo Adaptativo y Sensores',
      theme: appTheme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ProductService _productService = ProductService();
  final Battery _battery = Battery();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        final pages = [
          _buildProductsView(isMobile),
          _buildBatteryView(),
          _buildSensorsView(),
        ];

        final titles = [
          'Productos API',
          'Estado de Bateria en Tiempo Real',
          'Acelerometro en Tiempo Real',
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(titles[_selectedIndex]),
          ),
          body: SafeArea(
            child: isMobile
                ? pages[_selectedIndex]
                : Row(
                    children: [
                      NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (index) {
                          setState(() => _selectedIndex = index);
                        },
                        labelType: NavigationRailLabelType.selected,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.shopping_bag_outlined),
                            selectedIcon: Icon(Icons.shopping_bag),
                            label: Text('Productos'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.battery_charging_full_outlined),
                            selectedIcon: Icon(Icons.battery_charging_full),
                            label: Text('Bateria'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.sensors_outlined),
                            selectedIcon: Icon(Icons.sensors),
                            label: Text('Sensores'),
                          ),
                        ],
                      ),
                      const VerticalDivider(thickness: 1, width: 1),
                      Expanded(child: pages[_selectedIndex]),
                    ],
                  ),
          ),
          bottomNavigationBar: isMobile
              ? NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.shopping_bag_outlined),
                      selectedIcon: Icon(Icons.shopping_bag),
                      label: 'Productos',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.battery_charging_full_outlined),
                      selectedIcon: Icon(Icons.battery_charging_full),
                      label: 'Bateria',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.sensors_outlined),
                      selectedIcon: Icon(Icons.sensors),
                      label: 'Sensores',
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _buildProductsView(bool isMobile) {
    return FutureBuilder<List<Product>>(
      future: _productService.getProduct(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Center(child: Text('No hay productos disponibles'));
        }

        if (isMobile) {
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Card(
                child: ListTile(
                  leading: Image.network(
                    p.thumbnail,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image),
                  ),
                  title: Text(p.title),
                  subtitle: Text('USD ${p.price} | Rating: ${p.rating}'),
                ),
              );
            },
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            childAspectRatio: 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.network(
                          p.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('USD ${p.price} | Rating: ${p.rating}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBatteryView() {
    return StreamBuilder<BatteryState>(
      stream: _battery.onBatteryStateChanged,
      builder: (context, snapshot) {
        final state = snapshot.data ?? BatteryState.unknown;

        return FutureBuilder<int>(
          future: _battery.batteryLevel,
          builder: (context, levelSnapshot) {
            if (levelSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final level = levelSnapshot.data ?? 0;

            return Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        state == BatteryState.charging
                            ? Icons.battery_charging_full
                            : (level > 20 ? Icons.battery_full : Icons.battery_alert),
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nivel de Bateria: $level%',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Estado: ${_getBatteryStatusText(state)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSensorsView() {
    return StreamBuilder<AccelerometerEvent>(
      stream: accelerometerEventStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error en sensor: ${snapshot.error}'));
        }

        final event = snapshot.data;
        if (event == null) {
          return const Center(child: Text('No hay datos del sensor'));
        }

        final bool isInclined = event.x.abs() > 3.0 || event.y.abs() > 3.0;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: isInclined
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Acelerometro en Tiempo Real',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    _buildAxisRow('Eje X (Inclinacion Lateral)', event.x),
                    const SizedBox(height: 10),
                    _buildAxisRow('Eje Y (Inclinacion Frontal)', event.y),
                    const SizedBox(height: 10),
                    _buildAxisRow('Eje Z (Gravedad / Elevacion)', event.z),
                    const SizedBox(height: 20),
                    Text(
                      isInclined ? 'Estado: Dispositivo Inclinado' : 'Estado: Dispositivo Estable',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAxisRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _getBatteryStatusText(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return 'Cargando (Conectado)';
      case BatteryState.discharging:
        return 'Descargando (Desconectado)';
      case BatteryState.full:
        return 'Bateria Carga Completa';
      case BatteryState.connectedNotCharging:
        return 'Conectado (Sin cargar)';
      default:
        return 'Obteniendo estado...';
    }
  }
}