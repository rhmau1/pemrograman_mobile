import 'package:flutter/material.dart';
import '../widgets/inherited_state.dart';

/// Kelompok 9: TabBar & TabBarView, NavigationRail, BottomNavigationBar, PageRouteBuilder Catalog
class WidgetCatalogScreen extends StatefulWidget {
  const WidgetCatalogScreen({super.key});

  @override
  State<WidgetCatalogScreen> createState() => _WidgetCatalogScreenState();
}

class _WidgetCatalogScreenState extends State<WidgetCatalogScreen>
    with SingleTickerProviderStateMixin {
  // Kelompok 7: AnimationControllers for FadeTransition and ScaleTransition
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _animatedToggled = false;

  // Kelompok 6: ValueNotifier & StreamController
  final ValueNotifier<int> _clickCounter = ValueNotifier<int>(0);

  int _currentNavIndex = 0;
  int _selectedRailIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    _clickCounter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MusicAppThemeInherited(
      appTitle: "Katalog 10 Kelompok Widget Flutter",
      currentThemeMode: "Dark Spotify Theme",
      onToggleTheme: () {},
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Katalog Semua Widget"),
            bottom: const TabBar(
              isScrollable: true,
              indicatorColor: Color(0xFF1DB954),
              labelColor: Color(0xFF1DB954),
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "1. Layout & Structure"),
                Tab(text: "2. Text, Icon & Buttons"),
                Tab(text: "3. Form & Inputs"),
                Tab(text: "4. Async, State & Anim"),
                Tab(text: "5. Dialog, Nav & Lists"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildGroup1And2Section(context),
              _buildGroup3And4Section(context),
              _buildGroup5Section(context),
              _buildGroup6And7Section(context),
              _buildGroup8910Section(context),
            ],
          ),
          // Kelompok 9: BottomNavigationBar
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentNavIndex,
            selectedItemColor: const Color(0xFF1DB954),
            unselectedItemColor: Colors.grey,
            backgroundColor: const Color(0xFF181818),
            onTap: (index) {
              setState(() {
                _currentNavIndex = index;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(milliseconds: 600),
                  content: Text('BottomNavigationBar Item $index terpilih!'),
                ),
              );
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
              BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Katalog Grid'),
              BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Tentang'),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: KELOMPOK 1 & 2 (Layout & Structural)
  // ==========================================
  Widget _buildGroup1And2Section(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Kelompok 1: Layout Widgets", Colors.blue),
            const SizedBox(height: 10),

            // 1. Container & Padding
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text("• Container & Padding: Pembungkus layout dengan dekorasi, margin, dan padding."),
            ),
            const SizedBox(height: 10),

            // 2. Row & Column & Expanded & Flexible
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.blueAccent.withValues(alpha: 0.2),
                    child: const Text("Row -> Expanded (Flex 1)", style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.cyan.withValues(alpha: 0.2),
                    child: const Text("Row -> Flexible", style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 3. Stack & Align & Center & SizedBox
            Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey.shade900,
              child: Stack(
                children: [
                  const Center(
                    child: Text("Stack & Center Widget", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      color: Colors.redAccent,
                      child: const Text("Align TopRight Badge", style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ),
                  const Positioned(
                    bottom: 8,
                    left: 8,
                    child: Text("Positioned BottomLeft", style: TextStyle(fontSize: 11, color: Colors.greenAccent)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader("Kelompok 2: Struktural & App Widgets", Colors.lightBlueAccent),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("• MaterialApp: Root aplikasi dengan tema."),
                  Text("• Scaffold: Kerangka utama (AppBar, Body, BottomNav, Drawer, FAB)."),
                  Text("• AppBar: Bilah judul bagian atas."),
                  Text("• SafeArea: Menjaga UI dari notch & status bar."),
                  Text("• Drawer: Menu navigasi geser."),
                  Text("• BottomSheet: Panel dialog dari bawah layar."),
                  Text("• Center & Align: Memposisikan widget child secara presisi."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: KELOMPOK 3 & 4 (Text, Icons & Buttons)
  // ==========================================
  Widget _buildGroup3And4Section(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Kelompok 3: Teks & Ikon Widgets", Colors.greenAccent),
            const SizedBox(height: 10),

            // 1. Text & TextStyle
            const Text(
              "• Text Widget dengan TextStyle kustom (Bold & Colored)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent),
            ),
            const SizedBox(height: 8),

            // 2. RichText
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.white70),
                children: [
                  TextSpan(text: "• RichText: "),
                  TextSpan(text: "Teks Bercetak Tebal, ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                  TextSpan(text: "Teks Berwarna, ", style: TextStyle(color: Colors.cyan)),
                  TextSpan(text: "dan Teks Miring.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.pinkAccent)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 3. SelectableText
            const SelectableText(
              "• SelectableText: Pengguna dapat memblok dan menyalin teks ini.",
              style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10),

            // 4. Icon & ImageIcon
            Row(
              children: [
                const Icon(Icons.music_note, color: Color(0xFF1DB954), size: 30),
                const SizedBox(width: 10),
                const Text("Standard Icon"),
                const SizedBox(width: 20),
                const ImageIcon(
                  AssetImage('assets/images/p.jpg'),
                  color: Colors.amber,
                  size: 30,
                ),
                const SizedBox(width: 10),
                const Text("ImageIcon Asset"),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionHeader("Kelompok 4: Tombol (Button) Widgets", Colors.orangeAccent),
            const SizedBox(height: 10),

            // Button Variety Wrap
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () => _showMsg(context, "ElevatedButton ditekan"),
                  child: const Text("ElevatedButton"),
                ),
                TextButton(
                  onPressed: () => _showMsg(context, "TextButton ditekan"),
                  child: const Text("TextButton"),
                ),
                OutlinedButton(
                  onPressed: () => _showMsg(context, "OutlinedButton ditekan"),
                  child: const Text("OutlinedButton"),
                ),
                IconButton(
                  onPressed: () => _showMsg(context, "IconButton ditekan"),
                  icon: const Icon(Icons.thumb_up, color: Color(0xFF1DB954)),
                ),
                FloatingActionButton.small(
                  onPressed: () => _showMsg(context, "Mini FloatingActionButton ditekan"),
                  child: const Icon(Icons.add),
                ),
                PopupMenuButton<String>(
                  onSelected: (val) => _showMsg(context, "PopupMenu: $val"),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: "Option 1", child: Text("Option 1")),
                    PopupMenuItem(value: "Option 2", child: Text("Option 2")),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: Colors.white10,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("PopupMenuButton"),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // OverflowBar / ButtonBar
            const Text("ButtonBar / OverflowBar Widget:"),
            const SizedBox(height: 6),
            OverflowBar(
              spacing: 8,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text("Buka")),
                OutlinedButton(onPressed: () {}, child: const Text("Tutup")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: KELOMPOK 5 (Input & Form Widgets)
  // ==========================================
  Widget _buildGroup5Section(BuildContext context) {
    double sliderVal = 50.0;
    bool switchVal = true;
    bool checkVal = true;
    String radioVal = "A";

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Kelompok 5: Input & Form Widgets", Colors.purpleAccent),
                const SizedBox(height: 10),

                // Form wrapper
                Form(
                  child: Column(
                    children: [
                      // 1. TextField
                      const TextField(
                        decoration: InputDecoration(
                          labelText: "TextField biasa (Input Bebas)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 2. TextFormField
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "TextFormField (Dengan Validasi Form)",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Switch & Checkbox
                Row(
                  children: [
                    Switch(
                      value: switchVal,
                      activeThumbColor: const Color(0xFF1DB954),
                      onChanged: (v) => setLocalState(() => switchVal = v),
                    ),
                    Text("Switch: ${switchVal ? 'ON' : 'OFF'}"),
                    const SizedBox(width: 20),
                    Checkbox(
                      value: checkVal,
                      activeColor: const Color(0xFF1DB954),
                      onChanged: (v) => setLocalState(() => checkVal = v ?? false),
                    ),
                    Text("Checkbox: ${checkVal ? 'Checked' : 'Unchecked'}"),
                  ],
                ),
                const SizedBox(height: 10),

                // 4. Radio Group
                RadioGroup<String>(
                  groupValue: radioVal,
                  onChanged: (v) {
                    if (v != null) setLocalState(() => radioVal = v);
                  },
                  child: Row(
                    children: const [
                      Text("Radio Options: "),
                      Radio<String>(
                        value: "A",
                        activeColor: Color(0xFF1DB954),
                      ),
                      Text("Opsi A"),
                      Radio<String>(
                        value: "B",
                        activeColor: Color(0xFF1DB954),
                      ),
                      Text("Opsi B"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 5. Slider
                Text("Slider Value: ${sliderVal.round()}"),
                Slider(
                  value: sliderVal,
                  min: 0,
                  max: 100,
                  activeColor: const Color(0xFF1DB954),
                  onChanged: (v) => setLocalState(() => sliderVal = v),
                ),
                const SizedBox(height: 14),

                // 6. DatePicker & TimePicker Showcases
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (d != null && context.mounted) {
                          _showMsg(context, "Tanggal dipilih: ${d.day}/${d.month}/${d.year}");
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text("showDatePicker"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (t != null && context.mounted) {
                          _showMsg(context, "Waktu dipilih: ${t.format(context)}");
                        }
                      },
                      icon: const Icon(Icons.access_time, size: 16),
                      label: const Text("showTimePicker"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 4: KELOMPOK 6 & 7 (Async, State & Animations)
  // ==========================================
  Widget _buildGroup6And7Section(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Kelompok 6: Async & State Widgets", Colors.tealAccent),
            const SizedBox(height: 10),

            // 1. FutureBuilder
            FutureBuilder<String>(
              future: Future.delayed(const Duration(seconds: 1), () => "Data dari Future Selesai Dimuat!"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Row(
                    children: [
                      CircularProgressIndicator(strokeWidth: 2),
                      SizedBox(width: 10),
                      Text("FutureBuilder sedang memuat..."),
                    ],
                  );
                }
                return Text("• FutureBuilder Result: ${snapshot.data}", style: const TextStyle(color: Colors.greenAccent));
              },
            ),
            const SizedBox(height: 12),

            // 2. StreamBuilder
            StreamBuilder<int>(
              stream: Stream.periodic(const Duration(seconds: 1), (i) => i).take(60),
              builder: (context, snapshot) {
                return Text(
                  "• StreamBuilder Counter (Realtime): ${snapshot.data ?? 0} detik",
                  style: const TextStyle(color: Colors.cyanAccent),
                );
              },
            ),
            const SizedBox(height: 12),

            // 3. ValueListenableBuilder & InheritedWidget
            ValueListenableBuilder<int>(
              valueListenable: _clickCounter,
              builder: (context, count, child) {
                return ElevatedButton(
                  onPressed: () => _clickCounter.value++,
                  child: Text("• ValueListenableBuilder (Nilai: $count)"),
                );
              },
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (ctx) {
                final inheritedData = MusicAppThemeInherited.of(ctx);
                return Text(
                  "• InheritedWidget Data: ${inheritedData?.appTitle ?? 'None'}",
                  style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                );
              },
            ),
            const SizedBox(height: 24),

            _buildSectionHeader("Kelompok 7: Animation Widgets", Colors.pinkAccent),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => setState(() => _animatedToggled = !_animatedToggled),
              child: const Text("Toggle Semua Animasi"),
            ),
            const SizedBox(height: 12),

            // 1. AnimatedContainer
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              height: _animatedToggled ? 70 : 45,
              width: double.infinity,
              color: _animatedToggled ? Colors.purpleAccent : Colors.teal,
              alignment: Alignment.center,
              child: const Text("AnimatedContainer (Ukuran & Warna Berganti)"),
            ),
            const SizedBox(height: 10),

            // 2. AnimatedOpacity
            AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: _animatedToggled ? 1.0 : 0.3,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.deepOrange,
                child: const Text("AnimatedOpacity (Opasitas Memudar)"),
              ),
            ),
            const SizedBox(height: 10),

            // 3. AnimatedSwitcher
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _animatedToggled ? "AnimatedSwitcher State A" : "AnimatedSwitcher State B",
                key: ValueKey<bool>(_animatedToggled),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 14),

            // 4. Hero & ScaleTransition & FadeTransition
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Icon(Icons.favorite, color: Colors.redAccent, size: 36),
                ),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text("FadeTransition", style: TextStyle(color: Colors.yellowAccent)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 5: KELOMPOK 8, 9 & 10 (Dialog, Nav & Lists)
  // ==========================================
  Widget _buildGroup8910Section(BuildContext context) {
    return Row(
      children: [
        // Kelompok 9: NavigationRail
        NavigationRail(
          selectedIndex: _selectedRailIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedRailIndex = index;
            });
          },
          labelType: NavigationRailLabelType.selected,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.feedback),
              label: Text('Feedback'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.grid_on),
              label: Text('Grid List'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),

        Expanded(
          child: IndexedStack(
            index: _selectedRailIndex,
            children: [
              // Rail Index 0: Kelompok 8 (Dialog & Feedback)
              Scrollbar(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionHeader("Kelompok 8: Dialog & Feedback Widgets", Colors.amberAccent),
                    const SizedBox(height: 10),

                    // Banner Widget
                    MaterialBanner(
                      content: const Text("Ini adalah MaterialBanner Notifikasi!"),
                      leading: const Icon(Icons.info, color: Colors.amber),
                      backgroundColor: Colors.amber.withValues(alpha: 0.15),
                      actions: [
                        TextButton(
                          onPressed: () {},
                          child: const Text("DISMISS"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Progress Indicators
                    const Row(
                      children: [
                        CircularProgressIndicator(color: Color(0xFF1DB954)),
                        SizedBox(width: 16),
                        Expanded(child: LinearProgressIndicator(color: Color(0xFF1DB954))),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tooltip & Dialog Triggers
                    Tooltip(
                      message: "Pesan Tooltip Muncul!",
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.white10,
                        child: const Text("Tahan atau Hover di sini untuk Tooltip"),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("AlertDialog"),
                                content: const Text("Ini dialog konfirmasi showDialog()."),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
                                ],
                              ),
                            );
                          },
                          child: const Text("showDialog"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) => const SizedBox(
                                height: 150,
                                child: Center(child: Text("showModalBottomSheet Content")),
                              ),
                            );
                          },
                          child: const Text("BottomSheet"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("SnackBar Notifikasi!")),
                            );
                          },
                          child: const Text("SnackBar"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Rail Index 1: Kelompok 10 (List & Scrolling Showcase: GridView & CustomScrollView)
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildSectionHeader("Kelompok 10: List & Scrolling Widgets", Colors.redAccent),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.5,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF282828),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Center(
                              child: Text(
                                "GridView Item ${index + 1}",
                                style: const TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ),
                          );
                        },
                        childCount: 6,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("CustomScrollView + SliverList Showcase:"),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            child: Text("${index + 1}"),
                          ),
                          title: Text("SliverList Item ${index + 1}"),
                          subtitle: const Text("Dikontrol oleh CustomScrollView"),
                        );
                      },
                      childCount: 4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
      ),
    );
  }

  void _showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }
}
