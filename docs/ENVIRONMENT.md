# Entorno de desarrollo — S.A.P.O.

## 1. Estado conocido del entorno

| Componente | Tecnología / referencia | Estado |
|---|---|---|
| Sistema de trabajo | Windows | Entorno local del desarrollo. |
| Base de datos | PostgreSQL 18.7 | Instalado; versión comunicada durante la preparación del proyecto. Conviene confirmarla con `SELECT version();`. |
| Administración de BD | pgAdmin 4 | Disponible y utilizado para administrar la base local. La versión exacta de pgAdmin queda pendiente de consultar en Help → About. |
| Base local | `sapo_db` | Conexión confirmada en pgAdmin 4. La consulta del 26/11/2026 devuelve 1 organización, 7 tipos de incidente, 0 personas y 0 incidentes. |
| Backend | JavaScript, Node.js y Express | Stack elegido; API no implementada. En la captura de CMD del 26/11/2026, `node` y `npm` no se reconocen; instalación o PATH pendiente. |
| Frontend | HTML, CSS y JavaScript | Tecnología prevista; interfaz aún no implementada. |
| Control de versiones | Git y GitHub | Repositorio público disponible en GitHub. En la captura de CMD del 26/11/2026, `git` no se reconoce; instalación o PATH pendiente. |
| Seguimiento | GitHub Projects | Tablero de S.A.P.O. con Sprint 1 definido. |

Este inventario distingue lo que ya está instalado o creado de los componentes que solo están previstos. No se afirma que la aplicación Node.js/Express esté implementada o funcionando. `psql --version` aparece escrito en la captura, pero no se ve su ejecución ni su resultado; queda pendiente.

## 2. Requisitos previos previstos

Para desarrollar y ejecutar el prototipo se necesitará:
- PostgreSQL con la base `sapo_db` preparada.
- pgAdmin o cliente PostgreSQL equivalente para inspeccionar y administrar la base.
- Node.js y npm para instalar dependencias y ejecutar la futura API.
- Git para descargar, versionar y actualizar el proyecto.
- Navegador web moderno para probar la interfaz.

Antes de comenzar el backend se registrarán las versiones exactas con estos comandos en PowerShell o CMD. En la primera comprobación del 26/11/2026, `node`, `npm` y `git` devolvieron el mensaje de comando no reconocido. Habrá que instalarlos o corregir el PATH antes del Sprint 2:

```powershell
node --version
npm --version
git --version
psql --version
```

Para verificar la versión desde la base de datos:

```sql
SELECT version();
SELECT current_database(), current_schema();
```

## 3. Comprobación local inicial del 26/11/2026

La captura de pgAdmin 4 muestra una conexión activa a `sapo_db` en PostgreSQL 18. La consulta de contenido devuelve:

| Tabla | Filas |
|---|---:|
| ORGANIZACION | 1 |
| TIPO_INCIDENTE | 7 |
| PERSONA | 0 |
| INCIDENTE | 0 |

Estos resultados confirman que hay datos de referencia para organización y tipo de incidencia; aún no existen registros de personas ni incidencias. La captura no permite confirmar el número total de tablas ni de claves foráneas, porque el panel Data Output muestra el resultado de la última consulta ejecutada. Esos recuentos quedan pendientes de una consulta conjunta específica.

## 4. Base de datos existente

La base PostgreSQL `sapo_db` ya está creada y se ha ejecutado previamente un script SQL del esquema. En el Sprint 1 se revisa el modelo requerido por el circuito práctico y se contrasta el esquema instalado con el fichero SQL de referencia.

El fichero de referencia analizado declara 24 tablas y 31 claves foráneas. La coincidencia de estos recuentos en la instancia local es una comprobación inicial; no sustituye la revisión de columnas, índices, restricciones y triggers. Véase [modelo de datos](DATA_MODEL_SPRINT1.md).

## 5. Variables de entorno del futuro backend

Se ha preparado `backend/.env.example` como plantilla de nombres de configuración. Cuando se implemente la API:
1. Copiar el ejemplo a un archivo local `.env`.
2. Completar los valores únicamente en el archivo local.
3. No subir `.env`, contraseñas, tokens ni secretos a GitHub.

Variables previstas:
- `PORT`: puerto HTTP de la API.
- `DB_HOST`: servidor PostgreSQL.
- `DB_PORT`: puerto de PostgreSQL.
- `DB_NAME`: nombre de base de datos; inicialmente `sapo_db`.
- `DB_USER`: usuario de conexión.
- `DB_PASSWORD`: contraseña local, que nunca debe versionarse.

El archivo de ejemplo contiene valores de muestra no utilizables como credenciales. No existe todavía un backend que consuma esta configuración.

## 6. Datos iniciales ficticios

Los scripts de datos iniciales se mantendrán separados del esquema. La carga respetará las dependencias entre entidades y utilizará exclusivamente datos ficticios. La secuencia prevista se documenta en [database/seeds/README.md](../database/seeds/README.md).

## 7. Arranque de la aplicación

Todavía no se pueden proporcionar comandos de ejecución del producto: el backend y el frontend no están implementados. Cuando se cree el proyecto Node.js/Express y la interfaz, este apartado se completará con instalación de dependencias, configuración local y comandos de arranque verificados.
