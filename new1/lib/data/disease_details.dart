import '../models/disease_info.dart';

/// Comprehensive disease reference data for chilli plant diseases.
/// Each key MUST match the label string from labels.txt exactly.
const Map<String, DiseaseInfo> kDiseaseDetails = {
  // ──────────────────────────────────────────────────────────────────────
  // 0  Anthracnose
  // ──────────────────────────────────────────────────────────────────────
  'Anthracnose': DiseaseInfo(
    name: 'Anthracnose (Colletotrichum spp.)',
    overview:
        'Anthracnose is one of the most destructive fungal diseases of chilli '
        'pepper worldwide, caused primarily by Colletotrichum capsici, '
        'C. gloeosporioides, and C. acutatum. The pathogen thrives in warm '
        '(25–30 °C), humid conditions and can cause yield losses of 10–80 %. '
        'It attacks both pre- and post-harvest fruit, and can persist in seed '
        'and crop debris for over a year.',
    symptoms: [
      'Dark, sunken, circular to oval lesions on ripe and ripening fruit, often with concentric rings of black acervuli (spore-producing structures)',
      'Water-soaked spots on green fruit that enlarge rapidly and turn dark brown to black',
      'Soft rot of fruit tissue under the lesion; severely affected fruit shrivel and mummify on the plant',
      'Brown to dark-brown irregular spots on leaves, sometimes with shot-hole appearance',
      'Die-back of twigs and branches in severe infections starting from the tip downwards',
      'Seed discoloration and reduced seed viability in infected pods',
    ],
    management: [
      'Use certified disease-free, hot-water-treated seed (52 °C for 30 minutes)',
      'Apply protectant fungicides such as Mancozeb (0.25 %) or Chlorothalonil at 7–10 day intervals during flowering and fruiting',
      'Use systemic fungicides like Carbendazim (0.1 %) or Azoxystrobin when disease pressure is high',
      'Remove and destroy all infected plant debris, mummified fruit, and volunteer plants after harvest',
      'Practice crop rotation with non-solanaceous crops for at least 2–3 years',
      'Avoid overhead irrigation; use drip irrigation to reduce leaf wetness duration',
      'Space plants adequately (45–60 cm) for good air circulation',
      'Harvest fruit promptly at maturity; avoid injury during harvest and transport',
      'Plant resistant varieties such as CA-960, Arka Lohit, or Pant C-1 where available',
    ],
  ),

  // ──────────────────────────────────────────────────────────────────────
  // 1  bacterial_spot
  // ──────────────────────────────────────────────────────────────────────
  'bacterial_spot': DiseaseInfo(
    name: 'Bacterial Spot (Xanthomonas spp.)',
    overview:
        'Bacterial spot of chilli pepper is caused by Xanthomonas euvesicatoria '
        '(formerly X. campestris pv. vesicatoria). It is one of the most '
        'economically significant bacterial diseases in tropical and subtropical '
        'regions. The bacterium spreads through rain splash, overhead irrigation, '
        'contaminated seed, and infected transplants. Warm temperatures (24–30 °C) '
        'with frequent rainfall create ideal epidemic conditions. Yield losses '
        'can exceed 50 % in severe outbreaks.',
    symptoms: [
      'Small (2–5 mm), dark-green, water-soaked, circular spots on leaves that turn brown to black with yellow halos',
      'Spots may merge to form large, irregular necrotic areas causing extensive leaf blight',
      'Severe defoliation beginning from lower leaves upward, exposing fruit to sunscald',
      'Raised, scab-like, rough-textured lesions on fruit that crack open and allow secondary infections',
      'Elongated dark streaks on stems and petioles in advanced infections',
      'Stunted plant growth, reduced fruit size, and premature fruit drop',
    ],
    management: [
      'Use certified disease-free seed; treat seed with hot water (50 °C for 25 min) or sodium hypochlorite (1 % for 30 min)',
      'Apply copper-based bactericides (Copper hydroxide or Bordeaux mixture) preventatively every 7–10 days',
      'Combine copper sprays with Mancozeb to reduce copper-resistant strains',
      'Avoid working in the field when foliage is wet to prevent mechanical spread',
      'Practise strict crop rotation with non-host crops (cereals, legumes) for 2–3 years',
      'Remove and destroy all infected plant residues immediately after harvest',
      'Use drip irrigation instead of overhead sprinklers to minimise leaf wetness',
      'Disinfect all tools, stakes, and equipment with 10 % bleach solution between uses',
      'Plant resistant or tolerant varieties when locally available (e.g., lines with Bs2 or Bs3 resistance genes)',
    ],
  ),

  // ──────────────────────────────────────────────────────────────────────
  // 2  Cercospora leaf spot (frog eye leaf spot)
  // ──────────────────────────────────────────────────────────────────────
  'Cercospora leaf spot Cercospora capsicib (frog eye leaf spot)': DiseaseInfo(
    name: 'Cercospora Leaf Spot / Frog Eye Leaf Spot (Cercospora capsici)',
    overview:
        'Cercospora leaf spot, also known as frog eye leaf spot, is caused by '
        'the fungus Cercospora capsici. It is prevalent in warm, humid, '
        'tropical and subtropical regions and can cause significant defoliation, '
        'leading to 20–50 % yield reduction. The fungus survives on infected '
        'crop debris and spreads through wind-borne conidia and rain splash. '
        'Disease severity increases under prolonged leaf wetness (>10 hours) '
        'and temperatures of 25–35 °C.',
    symptoms: [
      'Circular to oval spots (3–10 mm) on leaves with a grey or white centre and dark-brown to reddish-purple border — the characteristic "frog eye" appearance',
      'Spots may develop tiny black dots (stromata) in the centre where spores are produced',
      'Older spots become papery and may fall out, giving a "shot-hole" look to the leaf',
      'Heavy infection causes progressive defoliation starting from older, lower leaves',
      'Reduced photosynthesis leading to smaller fruit, delayed maturity, and lower yields',
      'Spots occasionally appear on stems and petioles as elongated, dark lesions',
    ],
    management: [
      'Apply fungicides such as Mancozeb (0.25 %), Carbendazim (0.1 %), or Chlorothalonil at first sign of symptoms',
      'Use copper oxychloride (0.3 %) as a preventive spray during the rainy season',
      'Remove and destroy infected lower leaves and all crop residues after harvest',
      'Maintain wide spacing (50–60 cm between plants) for good air circulation',
      'Avoid overhead irrigation; water at the base of plants during early morning hours',
      'Rotate crops with non-solanaceous species for at least 2 seasons',
      'Use resistant cultivars where available; consult local seed catalogues for tolerant lines',
      'Apply balanced fertilisation — excess nitrogen promotes lush canopy and increases disease',
    ],
  ),

  // ──────────────────────────────────────────────────────────────────────
  // 3  Chilli Leaf Curl Disease
  // ──────────────────────────────────────────────────────────────────────
  'Chilli Leaf Curl Disease': DiseaseInfo(
    name: 'Chilli Leaf Curl Disease (Begomovirus complex)',
    overview:
        'Chilli leaf curl disease (ChiLCD) is caused by a complex of '
        'begomoviruses (family Geminiviridae), often in association with '
        'betasatellite molecules. The primary vector is the whitefly '
        'Bemisia tabaci. It is one of the most devastating viral diseases '
        'of chilli in South and Southeast Asia, capable of causing 50–100 % '
        'crop loss when infection occurs at the seedling stage. The virus '
        'cannot be chemically cured once a plant is infected.',
    symptoms: [
      'Upward curling, crinkling, and puckering of young leaves — the most characteristic symptom',
      'Thickening and leathery texture of leaves with swollen veins (vein enation)',
      'Reduced leaf size (leaf area may decrease by 60–70 %) with pale-yellow or chlorotic mottling',
      'Severe stunting of the plant; internodes become very short, giving a bushy appearance',
      'Flower drop and drastically reduced fruit set; any fruit produced is small and deformed',
      'In co-infection with betasatellites: small, enation-like outgrowths on the underside of leaves',
    ],
    management: [
      'Use virus-free nursery seedlings raised under whitefly-proof nylon net (40–50 mesh)',
      'Control whitefly vectors aggressively: install yellow sticky traps (12–15 per acre)',
      'Apply systemic insecticides — Imidacloprid (0.3 ml/L) or Thiamethoxam (0.2 g/L) — as seed treatment and foliar spray at 15-day intervals',
      'Spray neem-based products (Azadirachtin 0.03 %) as a repellent between chemical sprays',
      'Rogue out (uproot and destroy) infected plants immediately upon symptom detection to reduce virus inoculum',
      'Grow border rows of tall, non-host crops (maize, sorghum) as barrier/trap crops for whiteflies',
      'Avoid planting chilli near other Begomovirus-susceptible crops (tomato, tobacco, cotton)',
      'Plant resistant or tolerant cultivars: LCA-353, Pusa Jwala, Arka Meghana, or locally recommended varieties',
      'Avoid summer planting when whitefly populations peak; prefer early kharif or rabi sowing',
    ],
  ),

  // ──────────────────────────────────────────────────────────────────────
  // 4  Naarati Gana Weema (Healthy / No Disease)
  // ──────────────────────────────────────────────────────────────────────
  'Naarati Gana Weema': DiseaseInfo(
    name: 'Healthy Chilli Plant (නාරටි ගණ වීම)',
    overview:
        '"Naarati Gana Weema" translates to a healthy / normal growth condition '
        'in the chilli plant. This label indicates that the model has not '
        'detected any of the known disease patterns in the uploaded image. '
        'The plant appears to be in normal health. However, always confirm '
        'with visual inspection, as some early-stage diseases may not yet '
        'show clear symptoms.',
    symptoms: [
      'No visible disease lesions, spots, or discoloration on leaves or fruit',
      'Normal green foliage with no curling, wilting, or chlorosis',
      'Healthy stems without cankers or streaks',
      'Normal fruit development without scabs, sunken spots, or rot',
    ],
    management: [
      'Continue regular monitoring — scout fields at least twice a week for early symptoms',
      'Maintain balanced fertilisation (NPK as per soil test recommendations)',
      'Ensure proper irrigation scheduling to avoid water stress',
      'Practice preventive fungicide/bactericide sprays during high-risk weather (warm + humid)',
      'Keep the field weed-free to reduce alternate hosts for pests and diseases',
      'Follow crop rotation with non-solanaceous crops to break disease cycles',
    ],
  ),

  // ──────────────────────────────────────────────────────────────────────
  // 5  Powdery mildew - Leveillula taurica
  // ──────────────────────────────────────────────────────────────────────
  'Powdery mildew - Leveillula taurica': DiseaseInfo(
    name: 'Powdery Mildew (Leveillula taurica)',
    overview:
        'Powdery mildew on chilli is caused by the obligate fungal parasite '
        'Leveillula taurica (anamorph: Oidiopsis taurica). Unlike most powdery '
        'mildews, this species develops its mycelium INSIDE the leaf tissue '
        '(endophytic), with only the spore-bearing structures emerging on the '
        'leaf surface. It thrives in warm (20–25 °C), dry conditions with '
        'moderate humidity (50–70 % RH). Yield losses of 20–40 % are common '
        'in susceptible varieties. Severe infections cause premature leaf drop '
        'that exposes fruit to sunscald.',
    symptoms: [
      'White to greyish, powdery fungal growth (conidia) on the UNDERSIDE of leaves',
      'Corresponding yellow, chlorotic patches on the upper leaf surface directly above the fungal colonies',
      'As lesions age, the chlorotic patches turn brown and necrotic',
      'Premature defoliation starting from older, lower leaves and progressing upward',
      'Exposed fruit develop sunscald (white to tan scalded areas) due to loss of canopy shade',
      'Reduced fruit size and delayed ripening in heavily infected plants',
    ],
    management: [
      'Apply sulphur-based fungicides (wettable sulphur 0.2 %) at first appearance of symptoms; repeat every 10–15 days',
      'Use systemic fungicides such as Hexaconazole (0.1 %), Difenoconazole, or Azoxystrobin in alternation to prevent resistance',
      'Spray potassium bicarbonate (0.5 %) or neem oil (0.3 %) as organic alternatives',
      'Avoid excessive nitrogen fertilisation, which promotes dense canopy and disease-friendly microclimate',
      'Maintain adequate plant spacing (50–60 cm) and prune lower branches for better air movement',
      'Avoid overhead irrigation; use drip systems to keep foliage dry',
      'Remove and destroy heavily infected leaves to reduce spore load in the field',
      'Plant resistant or moderately resistant cultivars such as Arka Lohit, G-4, or LCA-235 where available',
      'Monitor regularly — early detection and prompt spraying are key to limiting spread',
    ],
  ),
};
