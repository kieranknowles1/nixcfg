export type WidgetProps = React.PropsWithChildren<{
  className: string
}>

export default function Widget(props: WidgetProps) {
  return <div className={`bg-slate-500 rounded-2xl p-1 m-1 ${props.className}`}>
    {props.children}
  </div>
}
