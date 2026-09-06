import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    const Color bauhausBlack = Color(0xFF121212);
    const Color bauhausRed = Color(0xFFD02020);
    const Color bauhausBlue = Color(0xFF1040C0);
    const Color bauhausYellow = Color(0xFFF0C020);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DETAIL'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(color: bauhausBlack, height: 4.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IMAGE SECTION
            Container(
              height: 320,
              decoration: const BoxDecoration(
                color: bauhausYellow,
                border: Border(bottom: BorderSide(color: bauhausBlack, width: 4)),
              ),
              child: Image.network(
                product.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.image_not_supported, size: 80, color: bauhausBlack),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CUISINE PILL
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: bauhausBlue,
                      border: Border.all(color: bauhausBlack, width: 3),
                      boxShadow: const [
                        BoxShadow(color: bauhausBlack, offset: Offset(4, 4), blurRadius: 0),
                      ],
                    ),
                    child: Text(
                      product.cuisine.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // TITLE
                  Text(
                    product.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                      letterSpacing: -1.5,
                      color: bauhausBlack,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CALORIES & RATING
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.caloriesPerServing} KCAL',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: bauhausRed,
                          letterSpacing: -1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: bauhausBlack,
                          border: Border.all(color: bauhausBlack, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: bauhausYellow, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // INFO GRID
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                    children: [
                      _buildInfoBlock('DIFFICULTY', product.difficulty.toUpperCase(), bauhausYellow),
                      _buildInfoBlock('PREP TIME', '${product.prepTimeMinutes} MIN', Colors.white),
                      _buildInfoBlock('COOK TIME', '${product.cookTimeMinutes} MIN', Colors.white),
                      _buildInfoBlock('SERVINGS', '${product.servings}', bauhausBlue, textColor: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // INSTRUCTIONS TITLE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: const BoxDecoration(
                      color: bauhausBlack,
                    ),
                    child: const Text(
                      'INSTRUCTIONS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // INSTRUCTIONS TEXT
                  ...product.instructions.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: bauhausRed,
                              shape: BoxShape.circle,
                              border: Border.all(color: bauhausBlack, width: 3),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                  color: bauhausBlack,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.name} ADDED TO CART', style: const TextStyle(fontWeight: FontWeight.bold))),
              );
            },
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: bauhausRed,
                border: Border.all(color: bauhausBlack, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: bauhausBlack,
                    offset: Offset(6, 6),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'ADD TO CART',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBlock(String title, String value, Color bgColor, {Color textColor = const Color(0xFF121212)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: const Color(0xFF121212), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFF121212), offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: textColor.withOpacity(0.8),
              letterSpacing: 1,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
