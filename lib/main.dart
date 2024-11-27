import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File; // Para evitar uso de Platform diretamente em web.
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Classificador de Flores",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade300),
        useMaterial3: true,
      ),
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
  File? _image; // Para Android/iOS
  XFile? _webImage; // Para Web/Desktop
  String? _classification;

  final ImagePicker _picker = ImagePicker();

  // Verifica se o dispositivo é móvel
  bool get _isMobile => !kIsWeb;

  // Função para capturar ou selecionar uma imagem
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          // Web
          _webImage = pickedFile;
        } else {
          // Dispositivos móveis
          _image = File(pickedFile.path);
        }
      });
    }
  }

  // Função para enviar e classificar imagem
  Future<void> _classifyImage() async {
    if (!kIsWeb && _image == null) return;
    if (kIsWeb && _webImage == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('colocar aqui depois o endereço da api'),
    );

    if (kIsWeb && _webImage != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          await _webImage!.readAsBytes(),
          filename: 'image.jpg',
        ),
      );
    } else if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _image!.path),
      );
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      setState(() {
        _classification = responseBody;
      });
    } else {
      setState(() {
        _classification = "Erro ao classificar a imagem";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classificador de Flores')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exibe a imagem selecionada/capturada
            if (!kIsWeb && _image != null) // Dispositivos móveis
              Image.file(_image!, height: 200)
            else if (kIsWeb && _webImage != null) // Web/Desktop
              Image.network(_webImage!.path, height: 200)
            else
              const Text('Nenhuma imagem selecionada'),
            const SizedBox(height: 20),

            // Exibe o botão "Tirar Foto" apenas para dispositivos móveis
            if (_isMobile) ...[
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.camera),
                child: const Text('Tirar Foto'),
              ),
              const SizedBox(height: 10),
            ],

            // Exibe o botão "Escolher da Galeria" para todos os dispositivos
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: const Text('Escolher da Galeria'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _classifyImage,
              child: const Text('Classificar Imagem'),
            ),

            // Exibe a classificação
            if (_classification != null) ...[
              const SizedBox(height: 20),
              Text('Classificação: $_classification'),
            ],
          ],
        ),
      ),
    );
  }
}
