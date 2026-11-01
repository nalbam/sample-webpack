# 열린 의존성 PR 검토 기록

이 문서는 열린 Dependabot PR 5건이 `main`에 이미 반영되었는지 판정한 기록입니다. 같은 변경을 다시 적용하지 않도록, PR을 닫거나 새 의존성 PR을 검토하기 전에 확인합니다.

## 기준

| 항목 | 값 |
|---|---|
| 조회 시각 | 2026-11-01T07:43:06Z |
| 기준 `main` SHA | `10f0763ba6c5ee6ca168fe0097c9ee8892a3bda0` ([#74](https://github.com/nalbam/sample-webpack/pull/74)) |
| 확인 파일 | `package.json`, `package-lock.json`의 `packages["node_modules/<이름>"]`, `webpack.config.js` |

### 조회 경로

- 계획 단계: `gh` 인증이 없어 공개 GitHub API로 조회했습니다. 이때 열린 PR은 #70·#67·#66·#64·#61의 5건이었습니다.
- 작업 단계: 인증된 `gh`로 아래 명령을 다시 실행했고, 조회에 성공했습니다. 열린 PR은 계획 단계와 같은 5건입니다. 다른 열린 PR은 없습니다.

  ```bash
  gh api --paginate 'repos/nalbam/sample-webpack/pulls?state=open&per_page=100'
  ```

### 5개 PR의 공통 상태

- 작성자는 `dependabot[bot]`이고, base SHA는 `89abd9821492ae16d37dbd2f5567a2655f19c597`(#71 이전)입니다.
- diff는 `package.json`의 한 줄만 바꿉니다(1 addition, 1 deletion). `package-lock.json`은 바꾸지 않습니다.
- `mergeable_state`는 `dirty`입니다. 현재 `main`과 충돌합니다.
- PR 검사는 `GitGuardian Security Checks` 통과만 있습니다. `build` 검사 결과는 없습니다.

## 판정

판정 값의 뜻은 다음과 같습니다.

- 동일 버전 반영: PR이 제안한 버전이 `main`에 이미 같은 버전으로 있습니다.
- 상위 버전 대체: `main`에 PR 제안보다 높은 버전이 있습니다.

버전 열의 manifest는 `package.json`의 선언 범위, lockfile은 `package-lock.json`의 실제 설치 버전입니다. Node.js 요구 사항은 lockfile에 기록된 해당 패키지의 `engines.node`입니다.

| PR | 패키지 | PR 제안 | manifest | lockfile | Node.js 요구 | 판정 | 근거 커밋 |
|---|---|---|---|---|---|---|---|
| [#70](https://github.com/nalbam/sample-webpack/pull/70) | `webpack-cli` (dev) | `^7.0.2` | `^7.3.1` | 7.3.1 | `>=20.9.0` | 상위 버전 대체 | #71 [`75a96d9`](https://github.com/nalbam/sample-webpack/commit/75a96d9e1d8cacfc276632d9af4b738e3d42ab5b) 7.2.3 → #74 [`10f0763`](https://github.com/nalbam/sample-webpack/commit/10f0763ba6c5ee6ca168fe0097c9ee8892a3bda0) 7.3.1 |
| [#67](https://github.com/nalbam/sample-webpack/pull/67) | `copy-webpack-plugin` (dev) | `^14.0.0` | `^14.0.0` | 14.0.0 | `>= 20.9.0` | 동일 버전 반영 | #71 [`75a96d9`](https://github.com/nalbam/sample-webpack/commit/75a96d9e1d8cacfc276632d9af4b738e3d42ab5b) |
| [#66](https://github.com/nalbam/sample-webpack/pull/66) | `css-loader` | `^7.1.4` | `^7.1.5` | 7.1.5 | `>= 18.12.0` | 상위 버전 대체 | #71 [`75a96d9`](https://github.com/nalbam/sample-webpack/commit/75a96d9e1d8cacfc276632d9af4b738e3d42ab5b) |
| [#64](https://github.com/nalbam/sample-webpack/pull/64) | `webpack-dev-server` (dev) | `^5.2.3` | `^6.1.0` | 6.1.0 | `>= 22.15.0` | 상위 버전 대체 | #71 [`75a96d9`](https://github.com/nalbam/sample-webpack/commit/75a96d9e1d8cacfc276632d9af4b738e3d42ab5b) |
| [#61](https://github.com/nalbam/sample-webpack/pull/61) | `style-loader` | `^4.0.0` | `^4.0.0` | 4.0.0 | `>= 18.12.0` | 동일 버전 반영 | #71 [`75a96d9`](https://github.com/nalbam/sample-webpack/commit/75a96d9e1d8cacfc276632d9af4b738e3d42ab5b) |

루트 패키지의 `engines.node`는 `>=22.15.0`입니다. 이 값은 `webpack-dev-server` 6.1.0의 요구 사항과 같습니다. CI는 Node.js 26을 사용합니다.

### 설정과 명령의 전환 근거

#71([`75a96d9`](https://github.com/nalbam/sample-webpack/commit/75a96d9e1d8cacfc276632d9af4b738e3d42ab5b))에서 설정과 명령을 현재 버전에 맞게 바꿨습니다. 그래서 manifest만 바꾸는 PR을 적용할 이유가 없습니다.

- `webpack.config.js`의 `devServer`: `contentBase`·최상위 `overlay`를 `static: './dist'`·`client.overlay`로 바꿨고, `webpack.HotModuleReplacementPlugin`을 지우고 `hot: true`만 남겼습니다. `webpack-dev-server` 4 이후의 설정 형식입니다.
- `webpack.config.js`의 CSS·asset 처리: CSS는 `MiniCssExtractPlugin.loader`와 `css-loader`로 처리합니다. 이미지·아이콘은 `url-loader` 대신 webpack 5의 `type: 'asset'`과 `parser.dataUrlCondition.maxSize`로 처리합니다. `file-loader`·`url-loader` 의존성은 지웠습니다.
- `package.json`의 명령: `start`는 `webpack && webpack-dev-server --mode development`에서 `webpack serve --mode development`로, `build`는 `npm install -s && webpack`에서 `webpack --mode production`으로 바꿨습니다.

## 반영함

- 이번 신규 변경: 없음. 이번 작업은 `package.json`, `package-lock.json`, 런타임 코드를 바꾸지 않습니다.
- 기존 `main` 반영: 5개 패키지 모두 #71 또는 #74로 이미 반영되어 있습니다. 위 판정 표를 참조하십시오.

## 닫아도 됨

5개 PR 모두 닫아도 됩니다. 이 문서는 PR을 머지하거나 닫지 않습니다. 닫기는 저장소 관리자가 합니다.

- [#70](https://github.com/nalbam/sample-webpack/pull/70) `webpack-cli` `^7.0.2`: `main`에 더 높은 7.3.1이 있습니다. #71이 7.2.3을, #74가 7.3.1을 반영했습니다. PR은 4.x base 기준이라 충돌합니다.
- [#67](https://github.com/nalbam/sample-webpack/pull/67) `copy-webpack-plugin` `^14.0.0`: #71이 같은 14.0.0을 반영했습니다. PR을 적용해도 바뀌는 것이 없습니다.
- [#66](https://github.com/nalbam/sample-webpack/pull/66) `css-loader` `^7.1.4`: #71이 더 높은 7.1.5를 반영했습니다. PR을 적용하면 선언 범위가 낮아집니다.
- [#64](https://github.com/nalbam/sample-webpack/pull/64) `webpack-dev-server` `^5.2.3`: #71이 더 높은 메이저 6.1.0을 반영했고, `devServer` 설정과 `webpack serve` 명령도 바꿨습니다. PR은 예전 `webpack-dev-server` 명령을 그대로 둔 base 기준입니다.
- [#61](https://github.com/nalbam/sample-webpack/pull/61) `style-loader` `^4.0.0`: #71이 같은 4.0.0을 반영했습니다. PR을 적용해도 바뀌는 것이 없습니다.

## 검증 결과

### 로컬 검증

작업 revision(`10f0763`, 이 문서 추가 전)에서 Node.js 26.13.0, npm 11.20.0으로 실행했습니다.

| 명령 | 결과 |
|---|---|
| `npm ci` | 종료 코드 0. 322개 패키지 설치, 취약점 0건 |
| `npm ls webpack-cli copy-webpack-plugin css-loader webpack-dev-server style-loader --depth=0` | 종료 코드 0. `webpack-cli@7.3.1`, `copy-webpack-plugin@14.0.0`, `css-loader@7.1.5`, `webpack-dev-server@6.1.0`, `style-loader@4.0.0` |
| `npm test` | 종료 코드 0. `install-failure`, `build-failure`, `success` 3개 통과 |
| `npm run build` | 종료 코드 0. `webpack 5.112.2 compiled successfully`. `dist/`에 `index.html`, `main.bundle.js`, `main.bundle.css`, `webpack.png`, `favicon.ico` 생성 |

로컬에서는 Docker 이미지 빌드와 Nginx 응답 검사를 실행하지 않았습니다.

### 기존 CI 결과

`main` `10f0763`의 push 이벤트 `build` 워크플로 [run 41202904526](https://github.com/nalbam/sample-webpack/actions/runs/41202904526)은 성공했습니다. 이 run은 `.github/workflows/push.yaml`로 다음 단계를 통과했습니다.

- `Test build.sh`, `Install dependencies`, `Build dist`, `Check dist`(`dist/` 파일 5개)
- `Build Docker image for check`, `Run Docker image check`(Nginx 컨테이너의 페이지·bundle·이미지·favicon 응답)
- `Build release platforms without push`(`linux/amd64`, `linux/arm64`)

이 문서를 추가한 PR의 `build` 결과는 이 기록에 포함하지 않습니다. 해당 PR의 검사 결과를 확인하십시오.

## 다시 확인하는 방법

새 Dependabot PR이 열리거나 이 기록을 갱신할 때 다음 순서로 확인합니다.

1. 열린 PR을 조회합니다. 조회가 실패하면 빈 목록으로 기록하지 말고 실패로 기록합니다.

   ```bash
   gh api --paginate 'repos/nalbam/sample-webpack/pulls?state=open&per_page=100' \
     --jq '.[] | [.number, .title, .base.sha] | @tsv'
   ```

2. PR의 diff와 검사 결과를 확인합니다.

   ```bash
   gh pr diff <번호> -R nalbam/sample-webpack
   gh pr checks <번호> -R nalbam/sample-webpack
   ```

3. 현재 manifest와 lockfile의 버전을 확인합니다. 선언 범위(`package.json`)만으로 설치 버전을 판단하지 않습니다.

   ```bash
   jq '.dependencies, .devDependencies' package.json
   jq -r '.packages | to_entries[] | select(.key | test("^node_modules/(webpack-cli|copy-webpack-plugin|css-loader|webpack-dev-server|style-loader)$")) | [.key, .value.version, (.value.engines.node // "")] | @tsv' package-lock.json
   ```

4. Node.js 26에서 설치 버전과 빌드를 확인합니다.

   ```bash
   npm ci
   npm ls webpack-cli copy-webpack-plugin css-loader webpack-dev-server style-loader --depth=0
   npm test
   npm run build
   ```

   `npm ls`가 0이 아닌 코드로 끝나면 lockfile과 설치 결과가 다릅니다. `npm ci`를 다시 실행하고 출력의 오류를 확인하십시오.
