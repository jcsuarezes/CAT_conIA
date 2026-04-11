# Modelo operativo (Markdown-only)

## Flujo estándar
1. Seleccionar prompt desde `catalog/index.md`.
2. Completar bloque de `Inputs` (sin cambiar configuración fija de organización).
3. Ejecutar prompt en el asistente.
4. Revisar `Validation Checklist`.
5. Registrar mejoras en `changelog/prompts-history.md`.

## Reglas del equipo
- Prompts: inglés.
- Documentación y coordinación: español.
- Para updates, comenzar con `dry run`.
- Cualquier cambio de plantilla sube versión en historial.
- Organización fija para prompts Azure DevOps: `https://dev.azure.com/`.
- Todo prompt nuevo debe agregarse a `catalog/index.md` antes de considerarse activo.

## Criterios de calidad
- Claridad en entradas obligatorias.
- Salidas auditables (old/new + rationale).
- Compatibilidad markdown en Azure DevOps.
- Sin exposición de secretos.
