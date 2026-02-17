import '../models/disease_info.dart';

/// Basic reference data used to show helpful context once a prediction is made.
/// Update the copy to match your agronomy team's requirements.
const Map<String, DiseaseInfo> kDiseaseDetails = {
  'Anthracnose': DiseaseInfo(
    name: 'Anthracnose',
    overview:
        'A fungal disease caused mainly by Colletotrichum species that thrives in warm, humid conditions and damages leaves, stems, and fruit.',
    symptoms: [
      'Sunken, dark lesions with concentric rings on ripe fruit',
      'Irregular brown spots on leaves that may merge into large necrotic areas',
      'Wilted shoots and premature fruit drop in severe outbreaks',
    ],
    management: [
      'Remove and destroy infected plant debris to cut down spore loads',
      'Apply protectant fungicides (e.g., chlorothalonil or copper) following local guidelines',
      'Improve field airflow with proper pruning and row spacing',
    ],
  ),
  'bacterial_spot': DiseaseInfo(
    name: 'Bacterial Spot',
    overview:
        'A bacterial infection (commonly Xanthomonas campestris pv. vesicatoria) that spreads through rain splash and contaminated tools.',
    symptoms: [
      'Small water-soaked lesions on leaves that turn dark and develop yellow halos',
      'Scab-like spots on fruit which reduce marketability',
      'Leaf drop and stunted growth under prolonged pressure',
    ],
    management: [
      'Use certified disease-free seed or transplants',
      'Rotate crops with non-host species for at least two seasons',
      'Apply copper-based bactericides and follow strict sanitation',
    ],
  ),
  'Cercospora leaf spot Cercospora capsicib (frog eye leaf spot)': DiseaseInfo(
    name: 'Cercospora Leaf Spot',
    overview:
        'A leaf-spotting disease triggered by Cercospora spp. characterized by circular "frog-eye" lesions.',
    symptoms: [
      'Circular, grey to tan lesions with reddish-purple margins on leaves',
      'Tiny black fruiting bodies (specks) in the lesion centres',
      'Premature defoliation starting from lower canopy',
    ],
    management: [
      'Maintain good field sanitation and destroy volunteer plants',
      'Use preventative fungicide sprays when weather is conducive',
      'Encourage airflow via pruning and wider plant spacing',
    ],
  ),
  'Chilli Leaf Curl Disease': DiseaseInfo(
    name: 'Chilli Leaf Curl Disease',
    overview:
        'A viral complex, often spread by whiteflies, that causes severe curling and distortion of chilli leaves and fruit.',
    symptoms: [
      'Upward curling and thickening of young leaves',
      'Reduced leaf size with pale-yellow mosaic patterns',
      'Stunted plants producing fewer and misshapen fruits',
    ],
    management: [
      'Control whitefly vectors with yellow sticky traps and selective insecticides',
      'Remove infected plants early to reduce virus reservoirs',
      'Adopt resistant or tolerant cultivars where available',
    ],
  ),
  'Naarati Gana Weema': DiseaseInfo(
    name: 'Naarati Gana Weema',
    overview:
        'A locally reported disorder associated with severe fruit cracking and leaf bronzing. Update this entry with region-specific research as you validate the classifier.',
    symptoms: [
      'Bronzed foliage with marginal scorching',
      'Malformed pods with longitudinal cracks',
      'Gradual decline in canopy density',
    ],
    management: [
      'Review fertiliser balance and soil moisture to rule out abiotic stress',
      'Consult regional extension services for recommended control products',
      'Remove heavily affected plants to limit spread while diagnostics are confirmed',
    ],
  ),
  'Powdery mildew - Leveillula taurica': DiseaseInfo(
    name: 'Powdery Mildew (Leveillula taurica)',
    overview:
        'A fungal disease favoured by warm days and cool nights, producing powdery growth on the underside of leaves.',
    symptoms: [
      'White, powder-like fungal growth on leaf undersides',
      'Yellowing chlorotic patches on upper leaf surfaces',
      'Premature leaf drop that exposes fruit to sunscald',
    ],
    management: [
      'Apply sulphur or triazole fungicides at the first sign of symptoms',
      'Improve airflow and reduce humidity within the canopy',
      'Avoid overhead irrigation and adopt drip systems when possible',
    ],
  ),
};
