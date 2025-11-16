import type { TriliumData } from "./bindings/TriliumData";
import Widget from "./components/Widget";
import { formatFilesize } from "./utils";

import trilium from './third_party/dashboard-icons/svg/triliumnext.svg'
import AppHeader from "./components/AppHeader";

export interface TriliumWidgetProps {
  data: TriliumData
}

export default function TriliumWidget(props: TriliumWidgetProps) {
  return <Widget>
    <AppHeader
      name="Trilium"
      description="Personal Knowledge Base"
      iconSrc={trilium}
    />
    <span>{formatFilesize(props.data.db_size)}</span>
  </Widget>
}
