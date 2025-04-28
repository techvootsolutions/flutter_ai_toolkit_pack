/*
 * Flutter AI Toolkit Pack
 *
 * Flutter AI Toolkit Pack is an all-in-one AI-powered toolkit designed to supercharge
 * your Flutter apps with cutting-edge generative and vision AI features using Hugging Face models.
 *
 * Core Features:
 * - AI Generative Chat: Create conversational AI chat interfaces using large language models.
 * - AI Image Generation: Generate images from text prompts using models like Stable Diffusion.
 * - AI Image Editing: Modify and enhance images using inpainting or style transformation techniques.
 * - AI Image Labeling: Recognize and classify content within images using AI labeling models.
 *
 * Key Highlights:
 * - Plug-and-play Hugging Face API integration.
 * - Easily configurable API token and base URL.
 * - Built-in loading state handling via ValueNotifier.
 * - Lifecycle hooks (onStart / onComplete) for custom actions.
 * - Supports both text-based and image-based AI models.
 * - Highly customizable for any generative or vision AI use case.
 *
 * Developed by Techvoot Solutions
 */

///Flutter AI Toolkit Pack
library;

///Ai Api Client
export 'src/ai_client/ai_api_client.dart';

///Ai Onnx Client
export 'src/ai_client/ai_onxx_client.dart';

///Ai Facial Client
export 'src/ai_client/ai_facial_kit_client.dart';

///Ai Gemini Client
export 'src/ai_client/ai_gemini_client.dart';

///Chat Bubble View
export 'src/widgets/ai_chat_bubble_view.dart';