enum StatutCompte {
  nouveau(value: 'Créé'),
  actif(value: 'Actif'),
  suspendu(value: 'Suspendu'),
  expire(value: 'Expiré'),
  desactive(value: 'Désactivé');

  const StatutCompte({required this.value});
  final String value;
}
