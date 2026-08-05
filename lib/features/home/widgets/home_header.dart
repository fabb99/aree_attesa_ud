import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 150,//42,
              height: 150,//42,
              decoration: BoxDecoration(
                //color: AppColors.gameA,
                borderRadius: BorderRadius.circular(12),
              ),
              // child: const Icon(
              //   Icons.location_city,
              //   color: Colors.white,
              //   size: 24,
              // ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/logo/sonar cities-04.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aree Attesa UD', style: AppTextStyles.heading3App,),
                  Text(
                    '',//'Protezione Civile · Udine',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Impara a conoscere\nla tua città', style: AppTextStyles.heading1),

        const SizedBox(height: 8),
        const Text(
           'Le aree di attesa sono individuate dalla Protezione Civile e '
      'riportate nel Piano Comunale di Protezione Civile, la guida che '
      'ti aiuta a essere pront@ in caso di emergenza!\n'
           'Tre giochi per esplorare le aree di attesa\n'
          'della Protezione Civile di Udine.',
          // 'Every Italian municipality is required to maintain a Municipal Civil Protection' 
          // 'Plan that identifies official emergency assembly areas for first assistance.'
          // 'Although these areas are formally mapped, most citizens are unaware of them.'
          // 'Born from a proposal by Udine CSB, this serious game helps users locate and '
          // 'recognise these spaces, turning an invisible layer of planning into knowledge that saves lives.',
          
          style: AppTextStyles.bodyWhite,
        ),
        // const SizedBox(height: 8),
        // const SizedBox(height: 8),
        // const Text(
        //   'ISTRUZIONI QUESTIONARIO:',
        //   style: AppTextStyles.heading3App,
        // ),
        // const SizedBox(height: 8),
        // const Text(
        //   '1. Prova le tre modalità di gioco:\n' 
        //   '    Campo Fiorito, Localizza l\'Area, GeoGuesser.\n'
        //   '2. Quando hai finito, torna alla schermata principale e premi\n' 
        // '    \'Vai al questionario\' per completare la valutazione.'
        // ),
      ],
    );
  }
}