# S.A.P.O. — Sistema Avanzado Policial Operativo

Prototipo académico de la asignatura **Proyecto de Ingeniería de Software (47GIIN), VIU**.

S.A.P.O. modela un escenario simulado de registro y consulta de incidencias asociadas a personas ficticias. Utiliza exclusivamente datos ficticios y no se conecta con sistemas policiales, judiciales ni administrativos reales. No es un producto de producción.

## Documentación y seguimiento

- [Product Backlog](docs/PRODUCT_BACKLOG.md)
- [Planificación Sprint 1](docs/SPRINT_1_PLAN.md)
- [Arquitectura de la solución](docs/ARCHITECTURE.md)
- [Estructura del proyecto](docs/PROJECT_STRUCTURE.md)
- [Entorno de desarrollo](docs/ENVIRONMENT.md)
- [Modelo de datos del circuito](docs/DATA_MODEL_SPRINT1.md)
- [Estrategia de datos iniciales ficticios](database/seeds/README.md)
- [Registro de trabajo del Sprint 1](docs/SPRINT_1_WORKLOG.md)
- [Comparación de versiones SQL](docs/SQL_REVIEW_SPRINT1.md)
- [Checklist de seguridad y privacidad](docs/SECURITY_CHECKLIST.md)
- [Tablero GitHub Projects](https://github.com/users/Zanguango/projects/1)

## Alcance del incremento práctico

El incremento académico se limita a un circuito operativo: registrar y consultar incidencias asociadas a personas ficticias. Incluye las operaciones necesarias sobre personas e incidencias, asociación entre ambas, persistencia, validaciones y autenticación con permisos básicos. Los demás módulos se conservan como visión futura y no se comprometen para esta entrega.

## Tecnologías previstas

- Backend: JavaScript, Node.js y Express (API REST).
- Frontend: HTML, CSS y JavaScript.
- Base de datos: PostgreSQL.
- Arquitectura: cliente-servidor por capas.

## Estructura inicial

- `backend/src`: configuración, controladores, middleware, repositorios, rutas y servicios de la futura API.
- `frontend`: recursos CSS y JavaScript de la interfaz web.
- `database/schema`: scripts versionados de estructura de base de datos.
- `database/seeds`: scripts de datos ficticios iniciales y relacionados.
- `tests`: pruebas unitarias y de integración.
- `docs`: backlog, planificación y documentación técnica.

La estructura es preparatoria: las carpetas no implican que las capas o funcionalidades estén implementadas.

## Estado

El Product Backlog y la planificación del Sprint 1 están definidos. La estructura inicial y la documentación de arquitectura se preparan de forma incremental. La implementación del backend y su conexión con PostgreSQL se abordarán en un sprint posterior.
