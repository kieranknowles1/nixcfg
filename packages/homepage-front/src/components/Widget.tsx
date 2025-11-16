export type WidgetProps = React.PropsWithChildren<{

}>

export default function Widget(props: WidgetProps) {
  return <div className={`bg-slate-700 rounded-2xl p-1 m-1 grid grid-cols-1`}>
    {props.children}
  </div>
}
