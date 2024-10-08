import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memoplace/ui/add/view/addpage.dart';
import 'package:memoplace/ui/add/view/settingslanguage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// InfoPage
class InfoDrawer extends StatefulWidget {
  const InfoDrawer({super.key});

  @override
  State<InfoDrawer> createState() => _InfoDrawer();
}

class _InfoDrawer extends State<InfoDrawer> {
  User? user = FirebaseAuth.instance.currentUser;

  final Uri url = Uri.parse(
      'https://six-entrance-6bc.notion.site/MemoPlace-edb72efeb04e4f478402670048de001e');
  final Uri googleFromurl = Uri.parse(
      'https://docs.google.com/forms/d/e/1FAIpQLSfGWcIVLPMoAI-YhooVh5GwOLftMWj9RzHFUwjagB0zkEYlsA/viewform?usp=sf_link');
  final Uri kiyaku = Uri.parse(
      'https://six-entrance-6bc.notion.site/bee86251f2614d959c66e7ef2372b306');

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.orange,
          ),
          child:
              Center(child: Text(AppLocalizations.of(context)!.about_this_App)),
        ),
        // 多言語化対応
        // SizedBox(
        //     child: Center(
        //         child: Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
        //   children: [
        //     Text(AppLocalizations.of(context)!.language),
        //     const SettingLanguagePage(),
        //   ],
        // ))),
        ListTile(
            title: Text(AppLocalizations.of(context)!.logout),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                await context.push('/login');
              }
            }),
        ListTile(
            title: Text(AppLocalizations.of(context)!.account),
            onTap: () async {
              await deleteUser(user!.uid);
              if (context.mounted) {
                await context.push('/login');
              }
            }),
        ListTile(
            title: Text(AppLocalizations.of(context)!.privacypolicy),
            onTap: () async {
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                throw 'Could not Launch $url';
              }
            }),
        ListTile(
            title: Text(AppLocalizations.of(context)!.rules),
            onTap: () async {
              if (await canLaunchUrl(kiyaku)) {
                await launchUrl(kiyaku);
              } else {
                throw 'Could not Launch $url';
              }
            }),
        ListTile(
            title: Text(AppLocalizations.of(context)!.license),
            onTap: () async {
              await context.push('/licensepage');
            }),
        ListTile(
            title: Text(AppLocalizations.of(context)!.inquiry),
            onTap: () async {
              if (await canLaunchUrl(googleFromurl)) {
                await launchUrl(googleFromurl);
              } else {
                throw 'Could not Launch $googleFromurl';
              }
            }),
        ListTile(
          title: Text('${AppLocalizations.of(context)!.version}1.0.2'),
        ),
      ],
    );
  }
}
