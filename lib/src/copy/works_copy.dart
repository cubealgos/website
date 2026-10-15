// SPDX-License-Identifier: Apache-2.0

/// The copy of the works pages (the work page and its facts), EN and DE (copy
/// v3, section 5; all rights reserved). The words of a single work are in its
/// data file.
library;

import 'package:website/src/content/work.dart';
import 'package:website/src/routes.dart';

/// A status: its label and the sentence under it.
typedef StatusText = ({String label, String? explanation});

/// A licence: the short form on a band, the form on the page.
typedef LicenceText = ({String short, String long});

/// All copy of the works pages in one language.
typedef WorksCopy = ({
  /// The link under a band; `{name}` is the work's name.
  String more,

  /// The label of the link back to the index (an arrow is drawn before it).
  String back,
  String aboutTitle,
  String factsTitle,
  String imagesTitle,
  String statusLabel,
  String licenceLabel,
  String changeDateLabel,
  String chainsLabel,
  String linksLabel,

  /// The fee row; `{fee}` is the fee text of the data file.
  String feeRow,

  /// The line of a grant-funded work; `{funder}` and `{programme}`.
  String funderLine,
  String licensorLine,
  String closing,
  String busl,
  Map<WorkStatus, StatusText> status,

  /// An app that is deployed reads "available" (copy v2, 5.2).
  StatusText appAvailable,
  Map<WorkLicence, LicenceText> licence,
  Map<WorkLink, String> links,
});

/// The works copy per language.
const Map<Lang, WorksCopy> worksCopy = {
  Lang.en: (
    more: 'Read more: {name}',
    back: 'All works',
    aboutTitle: 'What it does',
    factsTitle: 'Facts',
    imagesTitle: 'Images',
    statusLabel: 'Status',
    licenceLabel: 'Licence',
    changeDateLabel: 'Change date',
    chainsLabel: 'Deployed on',
    linksLabel: 'Links',
    feeRow: 'Fee · {fee}',
    funderLine: 'Funded by a grant from {funder} ({programme}).',
    licensorLine: 'Licensor: Cube Algos UG (haftungsbeschränkt)',
    closing:
        "Questions about this work? Ask them in public, in its repository's "
        'issues.',
    busl:
        'Anyone may use, call and build on the deployed contracts. Deploying '
        'a modified copy for others to use needs a licence from us. On the '
        'change date at the latest, the licence becomes Apache-2.0.',
    status: {
      WorkStatus.inDevelopment: (
        label: 'In development',
        explanation:
            'We are working on it. Once it is published, its source code is '
            'linked here.',
      ),
      WorkStatus.public: (
        label: 'Source public',
        explanation:
            'The source code is published. When we deploy the contracts, '
            'their addresses are listed here.',
      ),
      WorkStatus.deployed: (
        label: 'Deployed',
        explanation:
            'We have deployed the contracts on the chains listed below.',
      ),
    },
    appAvailable: (label: 'Available', explanation: null),
    licence: {
      WorkLicence.apache: (
        short: 'Apache-2.0',
        long: 'Apache-2.0, open source',
      ),
      WorkLicence.busl: (
        short: 'BUSL 1.1',
        long: 'BUSL 1.1: source-available, open use',
      ),
    },
    links: {
      WorkLink.source: 'Source code on GitHub',
      WorkLink.docs: 'Documentation',
      WorkLink.security: 'Report a vulnerability',
      WorkLink.audit: 'Audit report',
      WorkLink.release: 'Release notes',
      WorkLink.app: 'Open the app',
    },
  ),
  Lang.de: (
    more: 'Mehr erfahren: {name}',
    back: 'Alle Arbeiten',
    aboutTitle: 'Worum es geht',
    factsTitle: 'Steckbrief',
    imagesTitle: 'Bilder',
    statusLabel: 'Status',
    licenceLabel: 'Lizenz',
    changeDateLabel: 'Änderungsdatum',
    chainsLabel: 'Bereitgestellt auf',
    linksLabel: 'Links',
    feeRow: 'Gebühr · {fee}',
    funderLine: 'Gefördert von {funder} im Programm {programme}.',
    licensorLine: 'Lizenzgeberin: Cube Algos UG (haftungsbeschränkt)',
    closing:
        'Fragen zu dieser Arbeit? Stellen Sie sie öffentlich, in den Issues '
        'ihres Repositorys.',
    busl:
        'Die bereitgestellten Smart Contracts darf jeder nutzen, aufrufen '
        'und in eigene Produkte einbinden. Wer eine geänderte Kopie für '
        'andere bereitstellen will, braucht eine Lizenz von uns. '
        'Spätestens am Änderungsdatum wird daraus Apache-2.0.',
    status: {
      WorkStatus.inDevelopment: (
        label: 'In Entwicklung',
        explanation:
            'Wir arbeiten daran. Ist sie veröffentlicht, steht hier ihr '
            'Quelltext.',
      ),
      WorkStatus.public: (
        label: 'Quelltext öffentlich',
        explanation:
            'Der Quelltext ist veröffentlicht. Stellen wir die Smart '
            'Contracts bereit, stehen hier ihre Adressen.',
      ),
      WorkStatus.deployed: (
        label: 'Bereitgestellt',
        explanation:
            'Wir haben die Smart Contracts auf den unten genannten Chains '
            'bereitgestellt.',
      ),
    },
    appAvailable: (label: 'Verfügbar', explanation: null),
    licence: {
      WorkLicence.apache: (
        short: 'Apache-2.0',
        long: 'Apache-2.0, Open Source',
      ),
      WorkLicence.busl: (
        short: 'BUSL 1.1',
        long: 'BUSL 1.1: Quelltext einsehbar, Nutzung offen',
      ),
    },
    links: {
      WorkLink.source: 'Quelltext auf GitHub',
      WorkLink.docs: 'Dokumentation',
      WorkLink.security: 'Schwachstelle melden',
      WorkLink.audit: 'Prüfbericht',
      WorkLink.release: 'Release-Notizen',
      WorkLink.app: 'Zur App',
    },
  ),
};
