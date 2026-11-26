# Estructura inicial del proyecto

La estructura organiza el código y la documentación de S.A.P.O. de acuerdo con la arquitectura cliente-servidor por capas. Los directorios se crean como base de trabajo; su existencia no implica que las funcionalidades estén implementadas.

```text
SAPO/
├── README.md
├── .gitignore
├── docs/
│   ├── PRODUCT_BACKLOG.md
│   ├── SPRINT_1_PLAN.md
│   ├── ARCHITECTURE.md
│   ├── PROJECT_STRUCTURE.md
│   └── ENVIRONMENT.md
├── backend/
│   └── src/
│       ├── config/
│       ├── controllers/
│       ├── middleware/
│       ├── repositories/
│       ├── routes/
│       └── services/
├── frontend/
│   ├── css/
│   └── js/
├── database/
│   ├── schema/
│   └── seeds/
└── tests/
    ├── unit/
    └── integration/
```

## Directorios

| Ruta | Responsabilidad prevista |
|---|---|
| `docs/` | Backlog, planificación y documentación técnica y metodológica. |
| `backend/src/config/` | Configuración de la aplicación y acceso a parámetros de entorno. |
| `backend/src/controllers/` | Adaptación de peticiones HTTP a casos de uso. |
| `backend/src/middleware/` | Autenticación, autorización y tratamiento transversal de peticiones. |
| `backend/src/repositories/` | Acceso a datos y consultas PostgreSQL. |
| `backend/src/routes/` | Definición y agrupación de endpoints de la API REST. |
| `backend/src/services/` | Reglas de negocio y coordinación de operaciones. |
| `frontend/css/` | Hojas de estilo de la interfaz web. |
| `frontend/js/` | Lógica de interacción y consumo de la API desde el navegador. |
| `database/schema/` | Scripts SQL de definición y evolución del esquema versionado. |
| `database/seeds/` | Datos iniciales ficticios y datos de entidades vinculadas para pruebas. |
| `tests/unit/` | Pruebas unitarias. |
| `tests/integration/` | Pruebas de integración entre componentes y persistencia. |

## Convenciones iniciales

- Mantener la lógica de negocio en servicios, no en controladores HTTP.
- Mantener el acceso SQL encapsulado en repositorios.
- No incluir archivos `.env`, contraseñas, tokens ni datos personales reales.
- Versionar los scripts SQL que se utilicen para reproducir el esquema y los datos ficticios.
- Mantener separados el esquema de base de datos y los scripts de carga de datos.
- Añadir archivos de código cuando se implemente cada componente, no crear código vacío para simular funcionalidad.
