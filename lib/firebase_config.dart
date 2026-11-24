import 'package:firebase_core/firebase_core.dart';

// MOVIX: ainda sem projeto Firebase próprio.
// Quando criar o projeto (Fase 4: login Google/nuvem), preencha estes valores
// e troque kFirebaseConfigurado para true. Enquanto isso o app funciona 100% local.
const bool kFirebaseConfigurado = false;

const kFirebaseOptions = FirebaseOptions(
  apiKey: 'PREENCHER',
  appId: 'PREENCHER',
  messagingSenderId: 'PREENCHER',
  projectId: 'PREENCHER',
  storageBucket: 'PREENCHER',
);

const kWebClientId = 'PREENCHER';
