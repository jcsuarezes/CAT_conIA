# PromptOps for Azure DevOps

Repositorio **sin código** (solo Markdown) para reutilizar prompts en inglés orientados a Azure DevOps Work Items.

## Qué puedes hacer
- Obtener work items por ID o por WIQL.
- Actualizar work items (estado, prioridad, tags, título, descripción, asignación).
- Inyectar tablas y valores estructurados en campos de trabajo.
- Mantener trazabilidad de cambios de prompts.

## Estructura
- [Catálogo](catalog/index.md)
- [Prompts Azure DevOps](prompts/azure-devops)
- [Perfil por defecto](profiles/default.md)
- [Modelo operativo](docs/operating-model.md)
- [Fallos conocidos de IA y CLI](docs/ai-known-failures.md)
- [Patrones validados de comandos](docs/validated-command-patterns.md)
- [Seguridad](docs/security.md)
- [Historial](changelog/prompts-history.md)

## Uso rápido
1. Abre [catalog/index.md](catalog/index.md).
2. Elige un prompt según objetivo.
3. Completa el bloque `Inputs`.
4. Ejecuta el prompt en tu asistente.
5. Registra mejoras en [changelog/prompts-history.md](changelog/prompts-history.md).

## Reglas clave
- Prompts en inglés.
- Documentación operativa en español.
- No guardar `PAT` ni secretos en el repositorio.
- Organización fija para Azure DevOps prompts: `https://dev.azure.com/cat-digital`.
- Todo prompt nuevo debe registrarse en [catalog/index.md](catalog/index.md).

## Persistencia del framework
- Modelo principal: prompts markdown en `prompts/azure-devops/`.
- Los scripts en `scripts/` se consideran soporte operativo o legado, no la fuente principal de reglas.
- Evitar proliferación de scripts por caso (UI, Webservices, historia puntual); priorizar una guía reusable en prompts.
- Si se requiere automatización, preferir un flujo reusable antes que múltiples scripts ad hoc.
- Cualquier excepción debe quedar documentada en `changelog/prompts-history.md`.
