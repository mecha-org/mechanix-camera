import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_camera/core/utils/app_colors.dart';
import 'package:mechanix_camera/features/camera/bloc/camera_bloc.dart';

class CapturedImage extends StatelessWidget {
  const CapturedImage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        return switch (state) {
          CapturedImagePreview() => Stack(
            children: [
              Center(
                child: Image.file(
                  File(state.lastCapturedPath),
                  fit: BoxFit.cover,
                  cacheWidth: MediaQuery.of(context).size.width.toInt(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: state.files.isEmpty
                    ? const SizedBox.shrink()
                    : RepaintBoundary(
                        child: Container(
                          height: 70,
                          width: 620,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          child: RepaintBoundary(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: state.files.length,
                              itemBuilder: (context, index) {
                                return _ImageTile(
                                  path: state.files[index].path,
                                  isSelected:
                                      state.files[index].path ==
                                      state.lastCapturedPath,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.path, required this.isSelected});

  final String path;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<CameraBloc>().add(CameraCapturedImageSelected(path));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: isSelected
              ? Border.all(color: AppColors.selectionBorderColor, width: 2)
              : null,
        ),
        child: _ImageView(path: path),
      ),
    );
  }
}

class _ImageView extends StatelessWidget {
  const _ImageView({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 50,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ResizeImage(FileImage(File(path)), width: 50, height: 70),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
